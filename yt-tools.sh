#!/usr/bin/env bash
#
# yt-tools - Script para baixar vídeos, músicas e playlists do YouTube
#
# Descrição:
# Script interativo para download via yt-dlp, com suporte a metadados,
# capas, playlists e conversão de arquivos.
#
# Autor: Paulo Soares
# GitHub: https://github.com/soarespaullo/YT-Tools
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
        printf "\r      \r"
    done
}

# Atualização do yt-dlp
atualizar_yt_dlp() {
  echo -e "${YELLOW}Verificando modo de instalação do yt-dlp...${NC}"

  YTDLP_PATH=$(command -v yt-dlp)

  if dpkg -S "$YTDLP_PATH" &> /dev/null; then
    echo -e "${YELLOW}yt-dlp instalado via apt.${NC}"
    echo -e "${YELLOW}Atualizando via apt... Aguarde.${NC}"
    
    (
    sudo apt update > /dev/null 2>&1
    sudo apt install --only-upgrade -y yt-dlp > /dev/null 2>&1
    ) &
    spinner $!
    
    if [ $? -eq 0 ]; then
      echo -e "${GREEN}yt-dlp atualizado com sucesso via apt!${NC}"
    else
      echo -e "${RED}Falha ao atualizar yt-dlp via apt. Verifique sua conexão e repositórios.${NC}"
    fi
  else
    echo -e "${YELLOW}yt-dlp não instalado via apt. Atualizando com yt-dlp -U...${NC}"
    
    (
      yt-dlp -U > /tmp/yt_update.log 2>&1 
    ) &
    spinner $!
    
    if grep -q 'yt-dlp is up to date' /tmp/yt_update.log; then
      echo -e "${GREEN}yt-dlp já está atualizado!${NC}"
    elif grep -q 'Updated yt-dlp' /tmp/yt_update.log; then
      echo -e "${GREEN}yt-dlp atualizado com sucesso!${NC}"
    else
      echo -e "${RED}Falha na atualização do yt-dlp. Veja detalhes abaixo:${NC}"
      cat /tmp/yt_update.log
    fi

    rm -f /tmp/yt_update.log
  fi
}

# Remoção do yt-dlp
remover_yt_dlp() {
  echo -e "${YELLOW}Verificando como o yt-dlp foi instalado...${NC}"
  YTDLP_PATH=$(command -v yt-dlp)

  if [ -z "$YTDLP_PATH" ]; then
    echo -e "${RED}yt-dlp não está instalado.${NC}"
    return
  fi

  if dpkg -S "$YTDLP_PATH" &> /dev/null; then
    echo -e "${YELLOW}yt-dlp foi instalado via apt. Removendo...${NC}"
    (
      sudo apt remove -y yt-dlp > /dev/null 2>&1
    ) &
    spinner $!
    echo -e "${GREEN}yt-dlp removido via apt.${NC}"
  elif [[ "$YTDLP_PATH" == "/usr/local/bin/yt-dlp" ]]; then
    echo -e "${YELLOW}yt-dlp instalado manualmente. Removendo...${NC}"
    (
      sudo rm -f /usr/local/bin/yt-dlp > /dev/null 2>&1
    ) &
    spinner $!
    echo -e "${GREEN}yt-dlp removido de /usr/local/bin.${NC}"
  else
    echo -e "${RED}Não foi possível determinar o método de instalação de yt-dlp.${NC}"
    echo -e "${RED}Remova manualmente o binário em: $YTDLP_PATH${NC}"
  fi
}

# Instala yt-dlp se necessário
if ! command -v yt-dlp &> /dev/null; then
    echo -e "${YELLOW}yt-dlp não encontrado. Instalando...${NC}"
    (
        sudo curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp > /dev/null 2>&1
        sudo chmod a+rx /usr/local/bin/yt-dlp > /dev/null 2>&1
    ) &
    spinner $!
    command -v yt-dlp &> /dev/null && echo -e "\n${GREEN}yt-dlp instalado com sucesso!${NC}" || echo -e "\n${RED}Falha ao instalar yt-dlp.${NC}"
fi

# Instala ffmpeg se necessário
if ! command -v ffmpeg &> /dev/null; then
    echo -e "${YELLOW}ffmpeg não encontrado. Instalando...${NC}"
    (
        sudo apt update > /dev/null 2>&1
        sudo apt install -y ffmpeg > /dev/null 2>&1
    ) &
    spinner $!
    command -v ffmpeg &> /dev/null && echo -e "\n${GREEN}ffmpeg instalado com sucesso!${NC}" || echo -e "\n${RED}Falha ao instalar ffmpeg.${NC}"
fi

# Diretórios
MUSICAS_DIR="$HOME/Downloads/YT-Musicas"
VIDEOS_DIR="$HOME/Downloads/YT-Videos"
PLAYLIST_DIR="$HOME/Downloads/YT-Playlists"
mkdir -p "$MUSICAS_DIR" "$VIDEOS_DIR" "$PLAYLIST_DIR"

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
    echo "6) Remover yt-dlp"
    echo "7) Sair"
    echo -ne "${YELLOW}Digite sua opção [1-7]: ${NC}"
    read -r opcao

    case $opcao in
        1)
            read -r -p "Cole a URL do vídeo: " url
            if [[ -z "$url" ]]; then
                echo -e "${RED}Nenhuma URL fornecida. Retornando ao menu...${NC}"
                sleep 2
                continue
            fi
            echo -e "${YELLOW}Baixando música com capa e metadados...${NC}"
            yt-dlp -x --audio-format mp3 \
                   --embed-thumbnail \
                   --add-metadata \
                   --metadata-from-title "%(artist)s - %(title)s" \
                   -o "%(artist)s - %(title)s.%(ext)s" \
                   -P "$MUSICAS_DIR" "$url" > /dev/null 2>&1 &
            spinner $!
            echo -e "\n${GREEN}Música salva em: $MUSICAS_DIR${NC}"
            ;;
        2)
            read -r -p "Cole a URL do vídeo: " url
            if [[ -z "$url" ]]; then
                echo -e "${RED}Nenhuma URL fornecida. Retornando ao menu...${NC}"
                sleep 2
                continue
            fi
            echo "Escolha a qualidade do vídeo:"
            echo "1) 1080p"
            echo "2) 720p"
            echo "3) 480p"
            echo -ne "${YELLOW}Sua escolha: ${NC}"
            read -r qualidade

            case $qualidade in
                1) formato="bestvideo[height<=1080][vcodec^=avc1]+bestaudio[acodec^=mp4a]/best[ext=mp4]" ;;
                2) formato="bestvideo[height<=720][vcodec^=avc1]+bestaudio[acodec^=mp4a]/best[ext=mp4]" ;;
                3) formato="bestvideo[height<=480][vcodec^=avc1]+bestaudio[acodec^=mp4a]/best[ext=mp4]" ;;
                *) 
                    echo -e "${RED}Qualidade inválida, usando padrão (melhor disponível).${NC}"
                    formato="bestvideo[height<=1080][vcodec^=avc1]+bestaudio[acodec^=mp4a]/best[ext=mp4]"
                    ;;
            esac

            echo -e "${YELLOW}Baixando vídeo em mp4 na qualidade escolhida...${NC}"
            yt-dlp -f "$formato" --merge-output-format mp4 \
                   -o "%(title)s (%(resolution)s).%(ext)s" \
                   -P "$VIDEOS_DIR" "$url" > /dev/null 2>&1 &
            spinner $!
            echo -e "\n${GREEN}Vídeo salvo em: $VIDEOS_DIR${NC}"
            ;;
        3)
            read -r -p "Cole a URL da playlist: " url
            if [[ -z "$url" ]]; then
                echo -e "${RED}Nenhuma URL fornecida. Retornando ao menu...${NC}"
                sleep 2
                continue
            fi
                        echo -e "${YELLOW}Baixando playlist com capa e metadados...${NC}"
            yt-dlp -x --audio-format mp3 \
                   --embed-thumbnail \
                   --add-metadata \
                   --metadata-from-title "%(artist)s - %(title)s" \
                   -o "%(playlist_title)s - %(artist)s - %(title)s.%(ext)s" \
                   -P "$PLAYLIST_DIR" "$url" > /dev/null 2>&1 &
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
            read -r -p "Digite o formato de saída (ex: mp3, wav, mkv, gif): " ext
            output_file="${input_file%.*}_convert.$ext"
            echo -e "${YELLOW}Convertendo arquivo...${NC}"
            ffmpeg -i "$input_file" "$output_file" > /dev/null 2>&1 &
            spinner $!
            echo -e "\n${GREEN}Arquivo convertido salvo em: $output_file${NC}"
            ;;
        6)
            remover_yt_dlp
            ;;
        7)
            echo -e "${RED}Saindo... Até logo!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Opção inválida!${NC}"
            sleep 1
            ;;
    esac

    read -n 1 -s -r -p $'\nPressione qualquer tecla para voltar ao menu...'
done
