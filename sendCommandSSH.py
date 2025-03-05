from cryptography.fernet import Fernet
import paramiko
import time

# Utilisez la clé générée précédemment
key = b'your_generated_key_here'
cipher = Fernet(key)

# Déchiffrez les mots de passe au moment de l'exécution
encrypted_ssh_password = b'your_encrypted_ssh_password_here'
ssh_password = cipher.decrypt(encrypted_ssh_password).decode()

encrypted_super_password = b'your_encrypted_super_password_here'
super_password = cipher.decrypt(encrypted_super_password).decode()

def send_command_to_switch(ip, username, ssh_password, super_password, command):
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        ssh.connect(ip, username=username, password=ssh_password, timeout=10)
        shell = ssh.invoke_shell()
        shell.send("super\n")
        time.sleep(1)
        shell.send(f"{super_password}\n")
        time.sleep(1)
        shell.send(f"{command}\n")
        time.sleep(2)
        output = shell.recv(65535).decode()
        return output
    except paramiko.AuthenticationException:
        print("Erreur d'authentification. Vérifiez vos identifiants.")
    except paramiko.SSHException as ssh_exception:
        print(f"Erreur SSH: {ssh_exception}")
    except Exception as e:
        print(f"Une erreur inattendue s'est produite: {e}")
    finally:
        ssh.close()

def display_menu_and_execute():
    ip = input("Entrez l'adresse IP du switch : ").strip()
    
    commands = [
        "display interface brief",
        "display vlan",
        "display device",
        "display current-configuration"
    ]

    print("\nChoisissez une commande à exécuter :")
    for i, cmd in enumerate(commands, start=1):
        print(f"{i}. {cmd}")
    
    try:
        choice = int(input("\nEntrez le numéro de la commande : "))
        if 1 <= choice <= len(commands):
            selected_command = commands[choice - 1]
            print(f"\nExécution de la commande : {selected_command}\n")
            
            username = "admin"
            
            result = send_command_to_switch(ip, username, ssh_password, super_password, selected_command)
            print(result)
        else:
            print("Choix invalide. Veuillez réessayer.")
    except ValueError:
        print("Entrée invalide. Veuillez entrer un numéro.")

if __name__ == "__main__":
    display_menu_and_execute()
