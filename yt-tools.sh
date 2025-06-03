#!/usr/bin/env bash
#
# yt-tools - Script para baixar vídeos, músicas e playlists do YouTube
#
# Descrição:
# Script interativo para download via yt-dlp, com suporte a metadados,
# capas, playlists e conversão de arquivos.
#
# Autor: Paulo Soares
# GitHub: https://github.com/soarespaullo/yt-tools
# Data: 03-06-2025
#
# Uso:
# ./yt-tools.sh
#
# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m'

# Spinner para mostrar progresso
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while kill -0 "$pid" 2>/dev/null; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
}

# Função para atualizar yt-dlp tratando instalação via apt
atualizar_yt_dlp() {
  echo -e "${YELLOW}Verificando modo de instalação do yt-dlp...${NC}"

  YTDLP_PATH=$(command -v yt-dlp)

  if dpkg -S "$YTDLP_PATH" &> /dev/null; then
    echo -e "${YELLOW}yt-dlp instalado via apt.${NC}"
    echo -e "${YELLOW}Atualizando via apt... Aguarde.${NC}"
    sudo apt update > /dev/null 2>&1
    sudo apt install --only-upgrade -y yt-dlp > /dev/null 2>&1
    if [ $? -eq 0 ]; then
      echo -e "${GREEN}yt-dlp atualizado com sucesso via apt!${NC}"
    else
      echo -e "${RED}Falha ao atualizar yt-dlp via apt. Verifique sua conexão e repositórios.${NC}"
    fi
  else
    echo -e "${YELLOW}yt-dlp não instalado via apt. Atualizando com yt-dlp -U...${NC}"
    yt-dlp -U
  fi

  read -n 1 -s -r -p $'\nPressione qualquer tecla para voltar ao menu...'
}

# Verifica se yt-dlp está instalado, se não instala
if ! command -v yt-dlp &> /dev/null; then
    echo -e "${YELLOW}yt-dlp não encontrado. Instalando...${NC}"
    (
      sudo curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp > /dev/null 2>&1
      sudo chmod a+rx /usr/local/bin/yt-dlp > /dev/null 2>&1
    ) &
    spinner $!
    if command -v yt-dlp &> /dev/null; then
        echo -e "\n${GREEN}yt-dlp instalado com sucesso!${NC}"
    else
        echo -e "\n${RED}Falha ao instalar yt-dlp. Verifique sua conexão e tente novamente.${NC}"
    fi
fi

# Verifica se ffmpeg está instalado, se não instala
if ! command -v ffmpeg &> /dev/null; then
    echo -e "${YELLOW}ffmpeg não encontrado. Instalando...${NC}"
    (
        sudo apt update > /dev/null 2>&1
        sudo apt install -y ffmpeg > /dev/null 2>&1
    ) &
    spinner $!
    if command -v ffmpeg &> /dev/null; then
        echo -e "\n${GREEN}ffmpeg instalado com sucesso!${NC}"
    else
        echo -e "\n${RED}Falha ao instalar ffmpeg. Verifique sua conexão e repositórios.${NC}"
    fi
fi

# Diretórios padrão e logs
MUSICAS_DIR="$HOME/Downloads/YT-Musicas"
VIDEOS_DIR="$HOME/Downloads/YT-Videos"
PLAYLIST_DIR="$HOME/Downloads/YT-Playlists"
LOG_DIR="$HOME/Downloads/YT-Logs"
mkdir -p "$MUSICAS_DIR" "$VIDEOS_DIR" "$PLAYLIST_DIR" "$LOG_DIR"

DATA_ATUAL=$(date +%F)

# Loop principal
while true; do
    clear
    echo -e "${BLUE}"
    echo "██╗   ██╗████████╗████████╗ ██████╗  ██████╗ ██╗     ███████╗"
    echo "╚██╗ ██╔╝╚══██╔══╝╚══██╔══╝██╔═══██╗██╔═══██╗██║     ██╔════╝"
    echo " ╚████╔╝    ██║█████╗██║   ██║   ██║██║   ██║██║     ███████╗"
    echo "  ╚██╔╝     ██║╚════╝██║   ██║   ██║██║   ██║██║     ╚════██║"
    echo "   ██║      ██║      ██║   ╚██████╔╝╚██████╔╝███████╗███████║"
    echo "   ╚═╝      ╚═╝      ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝╚══════╝"
    echo -e "${NC}"
    echo -e "${YELLOW}Script para baixar vídeos, músicas e playlists do YouTube!${NC}\n"

    echo -e "${GREEN}Escolha uma opção:${NC}"
    echo "1) Baixar Música (MP3 com capa e metadados)"
    echo "2) Baixar Vídeo (Escolher qualidade e mp4)"
    echo "3) Baixar Playlist (MP3 com capa e metadados)"
    echo "4) Atualizar yt-dlp"
    echo "5) Converter arquivo de mídia"
    echo "6) Sair"
    echo -ne "${YELLOW}Digite sua opção [1-6]: ${NC}"
    read opcao

    case $opcao in
        1)
            read -p "Cole a URL do vídeo: " url
            echo -e "${YELLOW}Baixando música com capa e metadados...${NC}"
            LOG_FILE="$LOG_DIR/musicas_$DATA_ATUAL.log"
            yt-dlp -x --audio-format mp3 \
                   --embed-thumbnail \
                   --add-metadata \
                   --metadata-from-title "%(artist)s - %(title)s" \
                   -o "%(artist)s - %(title)s.%(ext)s" \
                   -P "$MUSICAS_DIR" "$url" >> "$LOG_FILE" 2>&1 &
            spinner $!
            echo -e "\n${GREEN}Música salva em: $MUSICAS_DIR${NC}"
            ;;
        2)
            read -p "Cole a URL do vídeo: " url
            echo "Escolha a qualidade do vídeo:"
            echo "1) 1080p"
            echo "2) 720p"
            echo "3) 480p"
            echo -ne "${YELLOW}Sua escolha: ${NC}"
            read qualidade

            case $qualidade in
                1) formato="bestvideo[height<=1080][vcodec^=avc1]+bestaudio[acodec^=mp4a]/best[ext=mp4]" ;;
                2) formato="bestvideo[height<=720][vcodec^=avc1]+bestaudio[acodec^=mp4a]/best[ext=mp4]" ;;
                3) formato="bestvideo[height<=480][vcodec^=avc1]+bestaudio[acodec^=mp4a]/best[ext=mp4]" ;;
                *) formato="best[ext=mp4]" ;;
            esac

            echo -e "${YELLOW}Baixando vídeo em mp4 na qualidade escolhida...${NC}"
            LOG_FILE="$LOG_DIR/videos_$DATA_ATUAL.log"
            yt-dlp -f "$formato" --merge-output-format mp4 \
                   -o "%(title)s (%(resolution)s).%(ext)s" \
                   -P "$VIDEOS_DIR" "$url" >> "$LOG_FILE" 2>&1 &
            spinner $!
            echo -e "\n${GREEN}Vídeo salvo em: $VIDEOS_DIR${NC}"
            ;;
        3)
            read -p "Cole a URL da playlist: " url
            echo -e "${YELLOW}Baixando playlist com capa e metadados...${NC}"
            LOG_FILE="$LOG_DIR/playlists_$DATA_ATUAL.log"
            yt-dlp -x --audio-format mp3 \
                   --embed-thumbnail \
                   --add-metadata \
                   --metadata-from-title "%(artist)s - %(title)s" \
                   -o "%(playlist_title)s - %(artist)s - %(title)s.%(ext)s" \
                   -P "$PLAYLIST_DIR" "$url" >> "$LOG_FILE" 2>&1 &
            spinner $!
            echo -e "\n${GREEN}Playlist salva em: $PLAYLIST_DIR${NC}"
            ;;
        4)
            atualizar_yt_dlp
            ;;
        5)
            read -e -p "Digite o caminho do arquivo para converter: " input_file

            if [[ ! -f "$input_file" ]]; then
                echo -e "${RED}Arquivo não encontrado!${NC}"
                sleep 2
                continue
            fi

            read -p "Digite o formato de saída (ex: mp3, wav, mkv, gif): " ext

            output_file="${input_file%.*}_convert.$ext"
            LOG_FILE="$LOG_DIR/conversoes_$DATA_ATUAL.log"

            echo -e "${YELLOW}Convertendo arquivo...${NC}"
            ffmpeg -i "$input_file" "$output_file" >> "$LOG_FILE" 2>&1 &
            spinner $!
            echo -e "\n${GREEN}Arquivo convertido salvo em: $output_file${NC}"
            ;;
        6)
            echo -e "${RED}Saindo... Até logo!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Opção inválida!${NC}"
            sleep 1
            ;;
    esac

    read -n 1 -s -r -p $'\nPressione qualquer tecla para continuar...'
done
