**Artela** — это новый Layer1 блокчейн, которое предоставляет разработчикам уникальную возможность создавать пользовательские расширения и динамические dApp. Уникальная архитектура сети обеспечивает широкую расширяемость и бесшовное взаимодействие между доменами

**Инвестировали: $6 000 000**

Инвесторы: Shima Capital, A&T Capital и другие

**Характеристики: 8CPU/16RAM/1TBSSD/Ubuntu: 20.04 / 22.04 — рекомендованные**

Сейчас проходит первый этап тестнета, проект сильно не шилят, можно залетать и пробоваться попасть в активный сет, оплачиваемый тестнет тоже будет. По планам майнет будет вторая половина 2024 года. Токен $ART подтверждён. Расписал установку детально по строкам. Также если вы хотите попробовать себя валидатором, то сейчас идёт набор, советую не скипать

###Начнем установку ноды. Выполним обновление содержимого сервера:
'''apt update && apt upgrade -y'''
'''apt install curl iptables build-essential git wget jq make gcc nano tmux htop lz4 nvme-cli pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip libleveldb-dev -y'''

**Установим язык программирования Go. На нем и работает нода Artela. По очереди выполните команды:**
'''sudo rm -rf /usr/local/go'''
'''curl -L https://go.dev/dl/go1.21.6.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local'''
'''echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> $HOME/.bash_profile'''
'''source .bash_profile'''

**Устанавливаем бинарный файл. Выполним команды:**
'''sudo apt install build-essential jq wget git curl  -y'''
'''cd $HOME'''
'''git clone https://github.com/artela-network/artela.git'''
'''cd artela'''
'''git checkout v0.4.7-rc6'''

**Следом выполняем команду:**
'''make install'''

Далее у Вас может возникнуть ошибка в запуске бинарного файла. Чтобы этого избежать, необходимо откорректировать разрешения файла artelad. Для этого выполним команду:
chmod +x $HOME/artela/artelad

ВАЖНО!: Укажите правильный путь к файлу artelad, путь, который указан в гайде может отличаться от Вашего!

Отлично, теперь перейдем к настройке непосредственно самой ноды и ее конфига. Выполним команды по очереди:
artelad config chain-id artela_11822-1
artelad config keyring-backend test
artelad config node tcp://localhost:26657

Перейдем к инициализации ноды, для этого выполним команду:
artelad init "Имя_вашей_ноды" --chain-id artela_11822-1
Где Имя_вашей_ноды - имя вашей ноды. Пишите имя ноды внутри кавычек.

Добавляем Genesis File и Addrbook:
curl -L https://snapshots-testnet.nodejumper.io/artela-testnet/genesis.json > $HOME/.artelad/config/genesis.json
curl -L https://snapshots-testnet.nodejumper.io/artela-testnet/addrbook.json > $HOME/.artelad/config/addrbook.json

Добавим сиды:
sed -i -e 's|^seeds *=.*|seeds = "211536ab1414b5b9a2a759694902ea619b29c8b1@47.251.14.47:26656,d89e10d917f6f7472125aa4c060c05afa78a9d65@47.251.32.165:26656,bec6934fcddbac139bdecce19f81510cb5e02949@47.254.24.106:26656,32d0e4aec8d8a8e33273337e1821f2fe2309539a@47.88.58.36:26656,1bf5b73f1771ea84f9974b9f0015186f1daa4266@47.251.14.47:26656"|' $HOME/.artelad/config/config.toml

Устанавливаем минимальную цену на газ:
sed -i -e 's|^minimum-gas-prices *=.*|minimum-gas-prices = "20000000000uart"|' $HOME/.artelad/config/app.toml

Ставим прунинг. Выполним все одной командой:
sed -i \
  -e 's|^pruning *=.*|pruning = "custom"|' \
  -e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
  -e 's|^pruning-interval *=.*|pruning-interval = "17"|' \
  $HOME/.artelad/config/app.toml

Загружаем последний Snap. Выполним команду:
curl "https://snapshots-testnet.nodejumper.io/artela-testnet/artela-testnet_latest.tar.lz4" | lz4 -dc - | tar -xf - -C "$HOME/.artelad"

Создаем сервис. Выполним все одной командой:
sudo tee /etc/systemd/system/artelad.service > /dev/null << EOF
[Unit]
Description=Artela node service
After=network-online.target
[Service]
User=$USER
ExecStart=$(which artelad) start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

Запускаем ноду. Выполним команды по очереди:
sudo systemctl daemon-reload
sudo systemctl enable artelad.service
sudo systemctl start artelad.service

Давайте проверим логи. Для этого выполните следующую команду и подождите, пока появятся строки с "HEIGHT":
sudo journalctl -u artelad.service -f --no-hostname -o cat

Сделаем обновление. Выполните команды по очереди:
sudo systemctl stop artelad

cd $HOME
rm -rf artela
git clone https://github.com/artela-network/artela
cd artela
git checkout v0.4.7-rc6
make install

sed -E 's/^pool-size[[:space:]]*=[[:space:]]*[0-9]+$/apply-pool-size = 10\nquery-pool-size = 30/' ~/.artelad/config/app.toml > ~/.artelad/config/temp.app.toml && mv ~/.artelad/config/temp.app.toml ~/.artelad/config/app.toml

sudo systemctl start artelad
sudo journalctl -u artelad -f --no-hostname -o cat

Создадим новый кошелек. Для этого выполните команду:
artelad keys add MyWallet

Вместо "MyWallet" введите имя Вашего кошелька БЕЗ кавычек.

Команда автоматически выведет Вам seed фразу и address Вашего кошелька. Сохраните данные в надежное место:

Для дальнейшей работы ноды нам необходимы тестовые токены, которые можно взять из крана в Дискорде проекта. Но сначала необходимо выполнить следующую команду, чтобы узнать более подробную информацию о кошельке:
artelad debug addr (ваш address)

Копируем EIP-55 address.

Идём в Discord проекта, переходим в ветку "#testnet-faucet". Нам нужно запросить тестовые токены. Сделать это можно отправив в чат "$request Ваш адрес EIP-55"

Бот отправит Вам тестовые токены на указанный Вами кошелек. Подождите примерно минут 5-7 после запроса тестовых токенов, после чего выполните команду для проверки баланса:
artelad q bank balances $(artelad keys show Имя_вашего_кошелька -a)

Создадим валидатора. Введем одну большую команду. "moniker", "details" замените на свои значения:
artelad tx staking create-validator \
--amount=1000000uart \
--pubkey=$(artelad tendermint show-validator) \
--moniker="" \
--identity=FFB0AA51A2DF5955 \
--details="" \
--chain-id=artela_11822-1 \
--commission-rate=0.10 \
--commission-max-rate=0.20 \
--commission-max-change-rate=0.01 \
--min-self-delegation=1 \
--from=M0zgiii \
--gas-prices=0.1uart \
--gas-adjustment=1.5 \
--gas=auto \
-y 

Теперь делегируем токены самому себе. Для этого выполним команду, в которой заранее необходимо заменить Имя_вашего_кошелька на имя Вашего кошелька:
artelad tx staking delegate $(artelad keys show Имя_вашего_кошелька --bech val -a) 1000000uart --from Имя_вашего_кошелька --chain-id artela_11822-1 --gas-prices 0.1uart --gas-adjustment 1.5 --gas auto -y 

Далее выполним команду, так же замените Имя_вашего_кошелька на имя Вашего кошелька:
artelad tx staking delegate M0zgiii 1000000uart --from Имя_вашего_кошелька --chain-id artela_11822-1 --gas-prices 0.1uart --gas-adjustment 1.5 --gas auto -y

Отлично! На данном этапе установка ноды Artela подошла к концу. Осталось лишь заполнить форму по ссылке



Дополнительные команды:

Посмотреть Sync Status:
artelad status 2>&1 | jq .SyncInfo.catching_up

Остановить ноду:
sudo systemctl stop artelad

Перезагрузить ноду:
sudo systemctl restart artelad

Просмотреть логи:
sudo journalctl -u artelad -f --no-hostname -o cat

Удалить ноду:
sudo systemctl stop artelad && sudo systemctl disable artelad && sudo rm /etc/systemd/system/artelad.service && sudo systemctl daemon-reload && rm -rf $HOME/.artelad && rm -rf artela && sudo rm -rf $(which artelad) 

Связь со мной: Telegram(@M0zgiii)




