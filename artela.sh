#!/bin/bash

# Цвета
GREEN='\033[0;32m'
NC='\033[0m' # Без цвета

# Функция для отображения логотипа
показать_логотип() {
  echo -e "${GREEN}"
  echo -e '███╗   ██╗ ██████╗ ██████╗ ███████╗██████╗ ██╗   ██╗███╗   ██╗███╗   ██╗███████╗██████╗ '
  echo -e '████╗  ██║██╔═══██╗██╔══██╗██╔════╝██╔══██╗██║   ██║████╗  ██║████╗  ██║██╔════╝██╔══██╗'
  echo -e '██╔██╗ ██║██║   ██║██║  ██║█████╗  ██████╔╝██║   ██║██╔██╗ ██║██╔██╗ ██║█████╗  ██████╔╝'
  echo -e '██║╚██╗██║██║   ██║██║  ██║██╔══╝  ██╔══██╗██║   ██║██║╚██╗██║██║╚██╗██║██╔══╝  ██╔══██╗'
  echo -e '██║ ╚████║╚██████╔╝██████╔╝███████╗██║  ██║╚██████╔╝██║ ╚████║██║ ╚████║███████╗██║  ██║'
  echo -e '╚═╝  ╚═══╝ ╚═════╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝'

  echo -e "\nПодписаться на канал may.crypto{🦅} чтобы быть в курсе самых актуальных нод - https://t.me/maycrypto\n"
  
  echo -e "${NC}"
}

# Функция для установки ноды
установить_ноду() {
  echo -e "${GREEN}============================================================"
  echo "Начало установки..."
  echo "============================================================${NC}"

  # Установка переменных
  if [ -z "$NODENAME" ]; then
    read -p "Введите имя ноды: " NODENAME
    echo 'export NODENAME='$NODENAME >> $HOME/.bash_profile
  fi
  if [ -z "$WALLET" ]; then
    echo "export WALLET=wallet" >> $HOME/.bash_profile
  fi
  echo "export ARTELA_CHAIN_ID=artela_11822-1" >> $HOME/.bash_profile
  source $HOME/.bash_profile

  # Обновление
  echo -e "${GREEN}Обновление системы...${NC}"
  sudo apt update && sudo apt upgrade -y

  # Установка пакетов
  echo -e "${GREEN}Установка необходимых пакетов...${NC}"
  sudo apt install curl iptables build-essential git wget jq make gcc nano tmux htop nvme-cli pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip lz4 -y

  # Установка Go
  echo -e "${GREEN}Установка Go...${NC}"
  sudo rm -rf /usr/local/go
  curl -L https://go.dev/dl/go1.21.6.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local
  echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> $HOME/.bash_profile
  source $HOME/.bash_profile

  # Загрузка бинарных файлов
  echo -e "${GREEN}Загрузка бинарных файлов Artela...${NC}"
  cd $HOME && rm -rf artela
  git clone https://github.com/artela-network/artela
  cd artela
  git checkout v0.4.7-rc7-fix-execution
  make install

  # Обновление библиотеки
  echo -e "${GREEN}Обновление библиотеки...${NC}"
  cd $HOME
  wget https://github.com/artela-network/artela/releases/download/v0.4.7-rc7-fix-execution/artelad_0.4.7_rc7_fix_execution_Linux_amd64.tar.gz
  tar -xvf artelad_0.4.7_rc7_fix_execution_Linux_amd64.tar.gz
  sudo mv $HOME/libaspect_wasm_instrument.so /usr/lib/

  # Конфигурация
  echo -e "${GREEN}Конфигурация Artela...${NC}"
  artelad config chain-id $ARTELA_CHAIN_ID
  artelad config keyring-backend test

  # Инициализация
  echo -e "${GREEN}Инициализация ноды...${NC}"
  artelad init $NODENAME --chain-id $ARTELA_CHAIN_ID

  # Загрузка genesis и addrbook
  echo -e "${GREEN}Загрузка genesis и addrbook...${NC}"
  wget -qO $HOME/.artelad/config/genesis.json https://public-snapshot-storage-develop.s3.ap-southeast-1.amazonaws.com/artela/artela_11822-1/genesis.json
  wget -O $HOME/.artelad/config/addrbook.json https://testnet-files.bonynode.online/artela/addrbook.json

  # Установка минимальной цены за газ
  echo -e "${GREEN}Настройка минимальной цены за газ...${NC}"
  sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"20000000000uart\"|" $HOME/.artelad/config/app.toml

  # Установка пиров и сидов
  echo -e "${GREEN}Настройка пиров и сидов...${NC}"
  SEEDS=""
  PEERS="5c9b1bc492aad27a0197a6d3ea3ec9296504e6fd@artela-testnet-peer.itrocket.net:30656,6fb1aa6a29475ebb4fe71270d124f2ffa2dd1bb4@162.19.234.110:36656,0c33c69cf6099d5f44a840dff08c02ee032191f1@94.16.31.30:3456,22533e3edfbeabec006591c3afae06fd970a3556@35.229.139.209:3456,7cc9992cdfb96a103f7ee9c34dd76076a0af98ff@80.190.82.45:3456,33a4eec53ff692a13d99901a296ba612f3586ac0@37.27.134.16:26656,fe55bcd1ee5c1425c1a8253e4bf745f9eab52cef@149.102.152.191:60656,8e1b7477ca2da4d246cab0cfd301dc1d17352215@65.109.62.39:11656,a94e93f8c072394f408180811ec2f76988da7a41@35.236.189.94:3456,da1b93e7bbf6f4bfa35486894ae0c3f035b42f28@35.201.233.155:3456,14fb77ff72e10aea7f307933a45e241ac29d993b@84.247.163.6:3456,d6034b52fe3c20764a7120c23e6a2eadc2caec2b@89.117.56.249:3456,811e56e1de32996f8ba83197065ea84b7b9a0a74@35.194.247.216:3456,23e30171028f5336cb1dc2b9d31dec0805ba7ea6@94.72.113.222:26656,3e1e63b2c93b722f37a7f3603b2d4563efbd3442@152.53.45.87:3456,0cabe01a4dfcef4f3105a575a5bea58b0310d7d2@185.252.234.24:3456,c4a372104340082d27a74f144c25d5ffc642d679@86.48.5.49:3456,e5427c90cdd49a2fa28677bdb345b586f0bcb77d@159.203.63.54:3456,5b77a3513fe0c64d71481465ea18584ee87492e4@173.212.220.218:25656,c4ad137b920899536d34f09eb37aaa314f739fe9@194.238.26.209:3456,d1d43cc7c7aef715957289fd96a114ecaa7ba756@65.21.198.100:23410"
  sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.artelad/config/config.toml

  # Отключение индексирования
  echo -e "${GREEN}Отключение индексирования...${NC}"
  indexer="null"
  sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.artelad/config/config.toml

  # Конфигурация обрезки
  echo -e "${GREEN}Настройка обрезки...${NC}"
  pruning="custom"
  pruning_keep_recent="100"
  pruning_keep_every="0"
  pruning_interval="10"
  sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.artelad/config/app.toml
  sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.artelad/config/app.toml
  sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.artelad/config/app.toml
  sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.artelad/config/app.toml
  sed -i "s/snapshot-interval *=.*/snapshot-interval = 0/g" $HOME/.artelad/config/app.toml

  # Обновление
  echo -e "${GREEN}Обновление конфигурации...${NC}"
  sed -i -e "s/iavl-disable-fastnode = false/iavl-disable-fastnode = true/" $HOME/.artelad/config/app.toml

  # Включение prometheus
  echo -e "${GREEN}Включение prometheus...${NC}"
  sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.artelad/config/config.toml

  # Создание службы
  echo -e "${GREEN}Создание службы Artela...${NC}"
  sudo tee /etc/systemd/system/artelad.service > /dev/null << EOF
[Unit]
Description=Artela Node Service
After=network-online.target
[Service]
User=$USER
ExecStart=$(which artelad) start
Environment="LD_LIBRARY_PATH=/root/libs"
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

  # Сброс
  echo -e "${GREEN}Сброс ноды Artela...${NC}"
  artelad tendermint unsafe-reset-all --home $HOME/.artelad --keep-addr-book
  curl https://testnet-files.itrocket.net/artela/snap_artela.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.artelad

  # Запуск службы
  echo -e "${GREEN}Запуск службы Artela...${NC}"
  sudo systemctl daemon-reload
  sudo systemctl enable artelad
  sudo systemctl restart artelad
  source $HOME/.bash_profile
}

# Функция для проверки синхронизации ноды
проверить_синхронизацию() {
  echo -e "${GREEN}Проверка синхронизации ноды...${NC}"
  source $HOME/.bash_profile
  artelad status 2>&1 | jq
  echo -e "${GREEN}Возвращаемся в главное меню...${NC}"
}

# Функция для создания кошелька
создать_кошелек() {
  read -p "Введите имя кошелька: " $WALLET
  echo -e "${GREEN}Создание кошелька $WALLET...${NC}"
  artelad keys add $WALLET
  echo -e "${GREEN}============================================================"
  echo "Сохраните адрес и Seed фразу"
  echo "============================================================${NC}"
  ARTELA_WALLET_ADDRESS=$(artelad keys show $WALLET -a)
  ARTELA_VALOPER_ADDRESS=$(artelad keys show $WALLET --bech val -a)
  echo 'export ARTELA_WALLET_ADDRESS='${ARTELA_WALLET_ADDRESS} >> $HOME/.bash_profile
  echo 'export ARTELA_VALOPER_ADDRESS='${ARTELA_VALOPER_ADDRESS} >> $HOME/.bash_profile
  artelad debug addr $ARTELA_WALLET_ADDRESS
  source $HOME/.bash_profile
  echo -e "${GREEN}Возвращаемся в главное меню...${NC}"
}

# Функция для импорта существующего кошелька
импортировать_кошелек() {
  read -p "Введите имя кошелька: " $WALLET
  echo -e "${GREEN}Импорт существующего кошелька $WALLET...${NC}"
  artelad keys add $WALLET --recover
  echo -e "${GREEN}============================================================"
  echo "Данные импортированного кошелька"
  echo "============================================================${NC}"
  ARTELA_WALLET_ADDRESS=$(artelad keys show $WALLET -a)
  ARTELA_VALOPER_ADDRESS=$(artelad keys show $WALLET --bech val -a)
  echo 'export ARTELA_WALLET_ADDRESS='${ARTELA_WALLET_ADDRESS} >> $HOME/.bash_profile
  echo 'export ARTELA_VALOPER_ADDRESS='${ARTELA_VALOPER_ADDRESS} >> $HOME/.bash_profile
  artelad debug addr $ARTELA_WALLET_ADDRESS
  source $HOME/.bash_profile
  echo -e "${GREEN}Возвращаемся в главное меню...${NC}"
}

# Функция для проверки баланса кошелька
проверить_баланс() {
  echo -e "${GREEN}Проверка баланса кошелька...${NC}"
  artelad q bank balances $ARTELA_WALLET_ADDRESS
  echo -e "${GREEN}Возвращаемся в главное меню...${NC}"
}

# Функция для создания валидатора
создать_валидатор() {
  echo -e "${GREEN}Создание валидатора...${NC}"
  artelad tx staking create-validator \
  --amount=1000000uart \
  --pubkey=$(artelad tendermint show-validator) \
  --moniker=$NODENAME \
  --chain-id=$ARTELA_CHAIN_ID \
  --commission-rate=0.10 \
  --commission-max-rate=0.20 \
  --commission-max-change-rate=0.01 \
  --min-self-delegation=1 \
  --from=$WALLET \
  --gas-prices=20000000000uart \
  --gas-adjustment=1.5 \
  --gas=auto \
  -y
}

# Функция для проверки логов
проверить_логи() {
  echo -e "${GREEN}Через 15 секунд начнется отображение логов Artela. Для возвращения в меню установочного скрипта используйте комбинацию клавиш CTRL+C${NC}"
  sleep 15
  trap - INT
  trap "echo -e '${GREEN}Возвращаемся в главное меню...${NC}'; return" INT
  journalctl -fu artelad -o cat
}

# Главное меню
while true
do
  показать_логотип
  sleep 2

  PS3='Выберите действие: '
  options=(
    "Установить ноду Artela"
    "Проверить синхронизацию ноды Artela"
    "Создать кошелек Artela"
    "Импортировать существующий кошелек Artela"
    "Проверить баланс кошелька Artela"
    "Создать валидатора Artela"
    "Проверить логи ноды Artela"
    "Выйти из установочного скрипта"
  )
  select opt in "${options[@]}"
  do
    case $opt in
      "Установить ноду Artela")
        установить_ноду
        break
        ;;
      "Проверить синхронизацию ноды Artela")
        проверить_синхронизацию
        break
        ;;
      "Создать кошелек Artela")
        создать_кошелек
        break
        ;;
      "Импортировать существующий кошелек Artela")
        импортировать_кошелек
        break
        ;;
      "Проверить баланс кошелька Artela")
        проверить_баланс
        break
        ;;
      "Создать валидатора Artela")
        создать_валидатор
        break
        ;;
      "Проверить логи ноды Artela")
        проверить_логи
        break
        ;;
      "Выйти из установочного скрипта")
        exit
        ;;
      *) echo -e "${GREEN}Неверный вариант $REPLY${NC}";;
    esac
  done
done
