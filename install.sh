#!/usr/bin/env bash
# install.sh — интерактивный установщик этого NixOS-конфига.
#
# Запускать на уже установленной NixOS (не из live-ISO):
#   cd <репозиторий>
#   sudo bash install.sh
#
# Что делает:
#   • берёт /etc/nixos/hardware-configuration.nix текущей системы
#     (или генерирует его, если файла нет);
#   • спрашивает имя пользователя и подставляет его в flake.nix,
#     /home/chu в b4/soap/stoat (если эти файлы есть);
#   • предлагает чекбоксами установить pi-агент и B4;
#   • комментирует/раскаментирует их импорты в main/core/default.nix;
#   • делает резервную копию изменяемых файлов;
#   • по желанию запускает nixos-rebuild boot.

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
cd "$SCRIPT_DIR"

if [[ "${EUID}" -ne 0 ]]; then
  echo "Запустите через sudo: sudo bash $0" >&2
  exit 1
fi

if [[ ! -e /etc/NIXOS ]]; then
  echo "Похоже, это не NixOS." >&2
  exit 1
fi

if [[ ! -f flake.nix || ! -d main ]]; then
  echo "Запускайте из корня репозитория (рядом должны быть flake.nix и main/)." >&2
  exit 1
fi

OWNER="${SUDO_USER:-$(stat -c '%U' .)}"
GROUP="$(id -gn "$OWNER" 2>/dev/null || echo "$OWNER")"

BACKUP_DIR="$SCRIPT_DIR/.installer-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"
cp -a flake.nix main .gitignore "$BACKUP_DIR"/

echo "Резервная копия: $BACKUP_DIR"

# ── hardware-configuration ───────────────────────────────────────────
if [[ -f /etc/nixos/hardware-configuration.nix ]]; then
  cp /etc/nixos/hardware-configuration.nix main/hardware-configuration.nix
  echo "hardware-configuration.nix взят из /etc/nixos."
else
  echo "Генерирую hardware-configuration.nix..."
  nixos-generate-config --show-hardware-config > main/hardware-configuration.nix
fi
chmod 644 main/hardware-configuration.nix

# ── имя пользователя ─────────────────────────────────────────────────
while true; do
  read -rp "Имя пользователя: " NEW_USER
  if [[ ! "$NEW_USER" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
    echo "Некорректное имя. Разрешены строчные буквы, цифры, _ и - (не с цифры)."
    continue
  fi
  if [[ "$NEW_USER" == "root" ]]; then
    echo "root не подходит."
    continue
  fi
  break
done

OLD_USER="$(sed -nE 's/^[[:space:]]*username[[:space:]]*=[[:space:]]*"([^"]+)".*/\1/p' flake.nix)"
OLD_USER="${OLD_USER%%$'\n'*}"
OLD_USER="${OLD_USER:-chu}"

if [[ "$OLD_USER" != "$NEW_USER" ]]; then
  sed -i "s/username = \"${OLD_USER}\";/username = \"${NEW_USER}\";/" flake.nix

  if grep -rlFZ --exclude-dir=.git "/home/${OLD_USER}" main >/dev/null 2>&1; then
    grep -rlFZ --exclude-dir=.git "/home/${OLD_USER}" main \
      | xargs -0 -r sed -i "s|/home/${OLD_USER}|/home/${NEW_USER}|g"
  fi
  echo "Пользователь: $OLD_USER → $NEW_USER"
else
  echo "Пользователь: $NEW_USER"
fi

# ── выбор компонентов ────────────────────────────────────────────────
PI=0
B4=0

if command -v whiptail >/dev/null 2>&1; then
  selected="$(
    whiptail --title "Компоненты" --separate-output --checklist \
      "Отметьте, что установить (пробел — переключить):" 15 64 2 \
      "pi" "Агент pi" ON \
      "b4" "B4" OFF \
      3>&1 1>&2 2>&3
  )" || {
    echo "Установка отменена. Изменения hardware/username уже применены; бэкап: $BACKUP_DIR" >&2
    exit 1
  }
  if grep -qx "pi" <<<"$selected"; then PI=1; fi
  if grep -qx "b4" <<<"$selected"; then B4=1; fi
else
  read -rp "Установить pi-агент? [y/N] " ans
  if [[ "$ans" =~ ^[Yy]$ ]]; then PI=1; fi
  read -rp "Установить B4? [y/N] " ans
  if [[ "$ans" =~ ^[Yy]$ ]]; then B4=1; fi
fi

# ── импорты pi/B4 ────────────────────────────────────────────────────
set_import() {
  local module="$1"
  local enabled="$2"
  local file="main/core/default.nix"
  local escaped="${module//./\\.}"

  if ! grep -qE "^[[:space:]]*#?[[:space:]]*\./${escaped}[[:space:]]*$" "$file"; then
    echo "Не найден импорт ./${module} в $file" >&2
    exit 1
  fi

  if [[ "$enabled" -eq 1 ]]; then
    sed -i -E "s|^[[:space:]]*#[[:space:]]*\./${escaped}[[:space:]]*$|      ./${module}|" "$file"
  else
    sed -i -E "s|^[[:space:]]*\./${escaped}[[:space:]]*$|      # ./${module}|" "$file"
  fi
}

set_import "pi.nix" "$PI"
set_import "b4-docker.nix" "$B4"

if [[ "$PI" -eq 1 ]]; then PI_TXT="да"; else PI_TXT="нет"; fi
if [[ "$B4" -eq 1 ]]; then B4_TXT="да"; else B4_TXT="нет"; fi

# ── владелец файлов ──────────────────────────────────────────────────
if [[ -n "$OWNER" && "$OWNER" != "root" ]]; then
  chown -R "$OWNER:$GROUP" "$BACKUP_DIR" main flake.nix .gitignore 2>/dev/null || true
fi

echo
echo "Готово:"
echo "  hardware: main/hardware-configuration.nix"
echo "  пользователь: $NEW_USER"
echo "  pi-агент: $PI_TXT"
echo "  B4: $B4_TXT"
echo "  бэкап: $BACKUP_DIR"
echo "  пароль: после reboot — sudo passwd $NEW_USER"

# ── сборка ───────────────────────────────────────────────────────────
read -rp "Запустить nixos-rebuild boot? [Y/n] " ans
if [[ ! "$ans" =~ ^[Nn]$ ]]; then
  nixos-rebuild boot --flake .#default
  echo
  echo "Сборка завершена. Перезагрузитесь: sudo reboot"
else
  echo
  echo "Позже: sudo nixos-rebuild boot --flake .#default"
fi
