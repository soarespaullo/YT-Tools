# 🎥🎵 yt-tools

**yt-tools** é um script Bash prático e intuitivo para baixar músicas, vídeos e playlists do `YouTube` com qualidade e facilidade. Além disso, permite converter arquivos de mídia e atualizar automaticamente o `yt-dlp` para garantir que você sempre tenha a versão mais recente!

---

## 🚀 Funcionalidades

- 🎧 **Baixar músicas** em MP3 com capa e metadados embutidos.
- 📹 **Baixar vídeos** em qualidade personalizada (1080p, 720p, 480p) sempre em MP4.
- 📃 **Baixar playlists** completas em MP3 com capa e metadados.
- 🔄 **Atualizar o yt-dlp** automaticamente, com suporte para instalações via `apt` ou direto.
- 🔧 **Converter arquivos de mídia** (áudio e vídeo) para vários formatos usando `ffmpeg`.
- ⏳ Spinner animado para indicar progresso durante operações em background.
- 📂 Organização automática dos arquivos em pastas padrão dentro de `~/Downloads`.
- ✅ Verifica e instala automaticamente `yt-dlp` e `ffmpeg`, caso não estejam instalados.

---

## ⚙️ Requisitos

- Linux com Bash
- `yt-dlp` (instalado/atualizado pelo script)
- `ffmpeg` (instalado pelo script se necessário)

---

## 📝 Como usar

1. Dê permissão de execução ao script:

```bash
chmod +x yt-tools.sh
```

2. Execute o script:

```bash
./yt-tools.sh
```

3. No menu interativo, escolha entre as opções:

- 🎵 Baixar música (MP3)

- 🎬 Baixar vídeo (MP4)

- 📜 Baixar playlist (MP3)

- 🔄 Atualizar yt-dlp

- 🔧 Converter arquivos de mídia

- ❌ Sair

4. Siga as instruções para inserir URLs e escolher formatos/qualidades.

## 📁 Estrutura das pastas criadas

- `~/Downloads/YT-Musicas` — músicas baixadas

- `~/Downloads/YT-Videos` — vídeos baixados

- `~/Downloads/YT-Playlists` — playlists baixadas

## 🔄 Atualização do yt-dlp

O script detecta se o `yt-dlp` foi instalado via `apt` ou não e orienta/realiza a atualização correta para manter sua ferramenta sempre atualizada.

## 🎛️ Conversão de arquivos

Converte arquivos de mídia para o formato desejado usando `ffmpeg`. Basta informar o caminho do arquivo e a extensão de saída (ex: mp3, mp4, wav, etc).

## ⚠️ Observações

- Uma conexão ativa com a internet é essencial para downloads e atualizações.

- O script utiliza pastas padrão para armazenar arquivos, sem opção de escolher diretórios personalizados.

---

## 🧾 Licença

Este projeto é licenciado sob a licença `MIT`. Veja o arquivo [**LICENSE**](https://github.com/soarespaullo/YT-Tools/blob/main/LICENSE) para mais detalhes.

---

## 👨‍💻 Autor

Feito com ❤️ por [**Paulo Soares**](https://soarespaullo.github.io/) – `Pull Requests` são bem-vindos!

- 📧 [**soarespaullo@proton.me**](mailto:soarespaullo@proton.me)

- 💬 [**@soarespaullo**](https://t.me/soarespaullo) no Telegram

- 💻 [**GitHub**](https://github.com/soarespaullo)

