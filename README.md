# Infrastruktura s více backendy a vyrovnáváním zátěže

## Popis
Tento projekt zavádí multi-backendovou infrastrukturu s konfigurovatelným počtem backendových serverů a vyrovnávačem zátěže NGINX pomocí Terraformu, Ansible a Dockeru. 

Infrastura je nasazená na platformě OpenNebula provozované ZČU FAV/KIV. 
VM jsou vytvořené za pomoci terraformu, který nasledně dynamicky předpřipraví i Inventory pro ansible přes šablony. Ansible zajistí instalaci a konfiguraci VM pro běh aplikace a i samotné stažení a spuštění aplikace. Samotná aplikace je dokerizovaná a její image je vyrvořen přes github actions. 

## Vlastnosti
- Konfigurovatelný počet backendů pomocí Terraform.
- Automatizované poskytování virtuálních strojů v systému OpenNebula.
- Vyrovnávání zátěže pomocí NGINX s dynamickým nastavováním upstreamu.
- Kontejnerizované backendové aplikace vyrovřeneé přes GitHub Actions.

## Předpoklady
- Terraform
- Ansible
- Docker
- Přístup k OpenNebula

## Struktura
- `ansible/`: Ansible playbooks.
- `backend/`: Backendová aplikace a její Dockerfile
- `.devcontainer/`: Nastavení devcontaineru pro stejné vývojové prostředí
- `.github/workflows/`: Github pipeline pro tvorbu a uložení dokerizovaného image backendová aplikace
- `terraform.tf`: Hlavní terraform script
- `inventory.tmpl`: Šablona pro dynamickou tvorbu inventory pro ansible
- `variables.tf`: Proměnné pro terraform.tf s popisem
- `terraform.tfvars`: Realné hodnoty proměných pro přetížených základních hodnot z `variables.tf`

## Příkazy pro rozchození projektu

1. Klonování repozitáře:
   ```bash
   git clone <repo-url>
   cd <repo-dir>
  
2. Nastavení prostředí:
   - V souboru `variables.tf` nebo `terraform.tfvars` (pokud je dostupný) nastavte `backend_count` a přihlašovací údaje pro OpenNebulu.

   
4. Spuštění vytovoření infrastruktury (terraform):
    ```bash
   terraform init
   terraform apply
   #+ potvzení
   
5. Instalace a nasazení kontejnerů:
   ```bash
   export ANSIBLE_HOST_KEY_CHECKING=False
   ansible-playbook -i dynamic_inventories/inventory ansible/main-play.yml

