import sys
import subprocess
import os
import glob

def check_and_install_dependencies():
    required_packages = ['telethon', 'colorama']
    installed_packages = []
    failed_packages = []

    for package in required_packages:
        try:
            __import__(package)
            installed_packages.append(package)
        except ImportError:
            print(f"\nMenginstall {package}...")
            try:
                subprocess.check_call([sys.executable, "-m", "pip", "install", package])
                installed_packages.append(package)
                print(f"{package} berhasil diinstall!")
            except subprocess.CalledProcessError:
                failed_packages.append(package)
                print(f"Gagal menginstall {package}")

    if failed_packages:
        print("\nBeberapa package gagal diinstall:", failed_packages)
        sys.exit(1)
    elif installed_packages != required_packages:
        print("\nSemua dependensi telah diinstall. Menjalankan ulang script...")
        os.execv(sys.executable, ['python3'] + sys.argv)
    else:
        print("\nSemua dependensi sudah terinstall!")

# Jalankan pengecekan dependensi
check_and_install_dependencies()

from telethon import TelegramClient, events
import asyncio
from colorama import Fore, Back, Style, init

# Inisialisasi colorama
init(autoreset=True)

def check_required_args():
    if len(sys.argv) < 6:
        print('')
        print(f"{Fore.RED}Error: Tidak cukup argumen!")
        print('')
        print(f"{Fore.YELLOW}Penggunaan: python3 script.py <api_id> <api_hash> <bot_token> <message> <chat_id> [opsional] <topik_id> <files_path>")
        print('')
        print(f'{Fore.YELLOW}Kirim pesan ke chat/channel (tanpa topic):')
        print(f'{Fore.GREEN}    > python3 main.py "API_ID" "API_HASH" "BOT_TOKEN" "Pesan Anda" "CHAT_ID"')
        print('')
        print(f'{Fore.YELLOW}Kirim pesan dan file ke chat/channel (tanpa topic):')
        print(f'{Fore.GREEN}    > python3 main.py "API_ID" "API_HASH" "BOT_TOKEN" "Pesan Anda" "CHAT_ID" "/path/to/file.txt"')
        print('')
        print(f'{Fore.YELLOW}Kirim pesan ke grup dengan topic:')
        print(f'{Fore.GREEN}    > python3 main.py "API_ID" "API_HASH" "BOT_TOKEN" "Pesan Anda" "GROUP_ID" "TOPIC_ID"')
        print('')
        print(f'{Fore.YELLOW}Kirim pesan dan file ke grup dengan topic:')
        print(f'{Fore.GREEN}    > python3 main.py "API_ID" "API_HASH" "BOT_TOKEN" "Pesan Anda" "GROUP_ID" "TOPIC_ID" "/path/to/file.txt')
        print('')
        print('')
        sys.exit(1)

# Fungsi untuk mengirim pesan
async def send_message_to_chat(client, chat_id, message, topic_id=None):
    try:
        if topic_id:
            await client.send_message(
                entity=chat_id,
                message=message,
                reply_to=topic_id
            )
        else:
            await client.send_message(
                entity=chat_id,
                message=message
            )
        print(f"{Fore.GREEN}✓ Pesan berhasil dikirim ke chat ID: {chat_id}")
    except Exception as e:
        print(f"{Fore.RED}✗ Error saat mengirim pesan: {e}")

# Fungsi untuk mengirim file
async def send_file_to_chat(client, chat_id, file_path, topic_id=None):
    try:
        if os.path.exists(file_path):
            if topic_id:
                await client.send_file(
                    chat_id,
                    file_path,
                    #caption=f"File dikirim: {os.path.basename(file_path)}",
                    reply_to=topic_id
                )
            else:
                await client.send_file(
                    chat_id,
                    file_path
                    #caption=f"File dikirim: {os.path.basename(file_path)}"
                )
            print(f"{Fore.GREEN}✓ File berhasil dikirim: {file_path}")
        else:
            print(f"{Fore.RED}✗ File tidak ditemukan: {file_path}")
    except Exception as e:
        print(f"{Fore.RED}✗ Error saat mengirim file: {e}")

async def main():
    # Cek argumen wajib
    check_required_args()

    # Mengambil argumen wajib
    api_id = sys.argv[1]
    api_hash = sys.argv[2]
    bot_token = sys.argv[3]
    message = sys.argv[4]
    chat_id = int(sys.argv[5])

    # Print konfigurasi
    print(f"\n{Fore.CYAN}Konfigurasi yang digunakan:")
    print(f"{Fore.WHITE}API ID: {api_id}")
    print(f"{Fore.WHITE}API Hash: {api_hash}")
    print(f"{Fore.WHITE}Bot Token: {bot_token}")
    print(f"{Fore.WHITE}Pesan: {message}")
    print(f"{Fore.WHITE}Chat ID: {chat_id}")

    # Inisialisasi client
    client = TelegramClient('bot_session', api_id, api_hash)
    await client.start(bot_token=bot_token)
    print(f"\n{Fore.GREEN}✓ Bot telah aktif!")

    try:
        # Cek apakah ada Topic ID (argumen ke-6)
        if len(sys.argv) > 6:
            topic_id = int(sys.argv[6])
            print(f"{Fore.WHITE}Topic ID: {topic_id}")
            
            # Kirim pesan ke grup dengan topic
            await send_message_to_chat(client, chat_id, message, topic_id)
            
            # Cek apakah ada file path (argumen ke-7)
            if len(sys.argv) > 7:
                file_path_pattern = sys.argv[7]
                print(f"{Fore.WHITE}File Path: {file_path_pattern}")
                for file_path in glob.glob(file_path_pattern):
                    await send_file_to_chat(client, chat_id, file_path, topic_id)

    except Exception as e:
        # Jika tidak ada Topic ID, kirim langsung ke chat/channel
        try:
            # Kirim pesan normal
            await send_message_to_chat(client, chat_id, message)
        
            # Cek apakah ada file path (argumen ke-6)
            if len(sys.argv) > 6:
                file_path_pattern = sys.argv[6]
                print(f"{Fore.WHITE}File Path: {file_path_pattern}")
                for file_path in glob.glob(file_path_pattern):
                    await send_file_to_chat(client, chat_id, file_path)
        except Exception as e:
            print(f"{Fore.RED}✗ Error: {e}")
    
    finally:
        await client.disconnect()
        print(f"\n{Fore.YELLOW}Bot telah dinonaktifkan")

if __name__ == '__main__':
    asyncio.run(main())