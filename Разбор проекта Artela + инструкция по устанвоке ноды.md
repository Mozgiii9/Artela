![image](https://github.com/Mozgiii9/SetupTheArtelaNode/assets/74683169/d275f044-220d-4d99-af47-8737ab5c25fa)

## Дата обновления файла: 23.04.2024 (Добавлен Bash скрипт для установки ноды Artela)

## Обзор проекта:

**Artela** — это новый Layer1 блокчейн, которое предоставляет разработчикам уникальную возможность создавать пользовательские расширения и динамические dApp. Уникальная архитектура сети обеспечивает широкую расширяемость и бесшовное взаимодействие между доменами

**Инвестировали: $6 млн. (Shima Capital, A&T Capital и др.)**

**Характеристики сервера (рекомендованные): 

- *CPU : 8 CORES;*
- *RAM : 16 GB;*
- *Storage : 1 TB SSD;*
- *OS : Ubuntu: 20.04 / 22.04*

Сейчас проходит первый этап тестнета, проект сильно не шилят, можно залетать и пробоваться попасть в активный сет, оплачиваемый тестнет тоже будет. По планам mainnet будет во второй половине 2024 года. Токен $ART подтверждён. Расписал установку детально по строкам. Также если вы хотите попробовать себя валидатором, то сейчас идёт набор, советую не скипать:

### Метод установки при помощи Bash скрипта:

**1. Обновление содержимого сервера:**

```
sudo apt update && sudo apt upgrade -y
```

**2. Установка дополнительного ПО для должной работы скрипта и ноды:**

```
sudo apt install curl git wget htop tmux build-essential jq make lz4 gcc unzip -y
```

**3. Установка и запуск самого Bash скрипта для установки ноды:**

```
source <(curl -s https://itrocket.net/api/testnet/artela/autoinstall/)
```

**Вводим имя кошелька, устанавливаем имя ноды (moniker'а) и оставляем 26 порт. Ждем конца установки ноды скриптом, как только пойдут логи - выходим из режима отображения логов при помощи комбинации клавиш CTRL+C**

**4. Установим апгрейд. Выполним команды по отдельности:**

```
cd $HOME
```

```
rm -rf artela
```

```
git clone https://github.com/artela-network/artela
```

```
cd artela
```

```
git checkout v0.4.7-rc6
```

```
make install
```

```
sed -E 's/^pool-size[[:space:]]*=[[:space:]]*[0-9]+$/apply-pool-size = 10\nquery-pool-size = 30/' ~/.artelad/config/app.toml > ~/.artelad/config/temp.app.toml && mv ~/.artelad/config/temp.app.toml ~/.artelad/config/app.toml
```

```
sudo systemctl restart artelad && sudo journalctl -u artelad -f
```
**5. Создадим кошелек:**

```
artelad keys add $WALLET
```

```
WALLET_ADDRESS=$(artelad keys show $WALLET -a)
```

```
VALOPER_ADDRESS=$(artelad keys show $WALLET --bech val -a)
```

```
echo "export WALLET_ADDRESS="$WALLET_ADDRESS >> $HOME/.bash_profile
```

```
echo "export VALOPER_ADDRESS="$VALOPER_ADDRESS >> $HOME/.bash_profile
```

```
source $HOME/.bash_profile
```

```
artelad status 2>&1 | jq
``` 

```
artelad query bank balances $WALLET_ADDRESS
```

**6. Идём в [Discord](https://discord.gg/bzru3ReY) проекта, переходим в ветку "#testnet-faucet". Нам нужно запросить тестовые токены. Сделать это можно отправив в чат "$request <Ваш адрес кошелька>"**
![image](https://github.com/Mozgiii9/SetupTheArtelaNode/assets/74683169/1f7c24a0-1215-4af0-80ed-b756986557eb)


Бот отправит Вам тестовые токены на указанный Вами кошелек. Подождите примерно минут 5-7 после запроса тестовых токенов, после чего выполните команду для проверки баланса:
```
artelad q bank balances $(artelad keys show Имя_вашего_кошелька -a)
```

### 17. Создадим валидатора. Введем одну большую команду. "moniker", "from" замените на свои значения. Обратите внимание на кавычки:
```
artelad tx staking create-validator \
--amount=1000000uart \
--pubkey=$(artelad tendermint show-validator) \
--moniker="Имя_вашей_ноды" \
--identity=FFB0AA51A2DF5955 \
--details="-" \
--chain-id=artela_11822-1 \
--commission-rate=0.10 \
--commission-max-rate=0.20 \
--commission-max-change-rate=0.01 \
--min-self-delegation=1 \
--from=Имя_вашего_кошелька \
--gas-prices=0.1uart \
--gas-adjustment=1.5 \
--gas=auto \
-y
```

**Найти свою ноду можно в [эксплорере](https://testnet.itrocket.net/artela/staking) по адресу кошелька или по хэшу(txhash) транзакции, которой Вы создали ноду.

### Метод установки ноды вручную:

### **1. Начнем установку ноды. Выполним обновление содержимого сервера:**

```
apt update && apt upgrade -y
```

```
apt install curl iptables build-essential git wget jq make gcc nano tmux htop lz4 nvme-cli pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip libleveldb-dev -y
```

**2. Установим язык программирования Go. На нем и работает нода Artela. По очереди выполните команды:**

```
sudo rm -rf /usr/local/go
```

```
curl -L https://go.dev/dl/go1.21.6.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local
```

```
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> $HOME/.bash_profile
```

```
source .bash_profile
```

**3. Устанавливаем бинарный файл. Выполним команды:**

```
sudo apt install build-essential jq wget git curl  -y
```

```
cd $HOME
```

```
git clone https://github.com/artela-network/artela.git
```

```
cd artela
```

```
git checkout v0.4.7-rc6
```
**4. Следом выполняем команду:**

```
make install
```


**Далее у Вас может возникнуть ошибка в запуске бинарного файла. Чтобы этого избежать, необходимо откорректировать разрешения файла artelad. Для этого выполним команду:**

```
chmod +x $HOME/artela/artelad
```


#### ВАЖНО!: Укажите правильный путь к файлу artelad, путь, который указан в гайде может отличаться от Вашего!
![image](https://github.com/Mozgiii9/SetupTheArtelaNode/assets/74683169/fc8e1625-335b-4046-bc78-b412ca8f7ca6)


**5. Отлично, теперь перейдем к настройке непосредственно самой ноды и ее конфига. Выполним команды по очереди:**

```
artelad config chain-id artela_11822-1
```

```
artelad config keyring-backend test
```

```
artelad config node tcp://localhost:26657
```

**6. Перейдем к инициализации ноды, для этого выполним команду:**

```
artelad init "Имя_вашей_ноды" --chain-id artela_11822-1
```

**Где Имя_вашей_ноды - имя вашей ноды. Пишите имя ноды внутри кавычек.**

**7. Добавляем Genesis File и Addrbook:**

```
curl -L https://snapshots-testnet.nodejumper.io/artela-testnet/genesis.json > $HOME/.artelad/config/genesis.json
```

```
curl -L https://snapshots-testnet.nodejumper.io/artela-testnet/addrbook.json > $HOME/.artelad/config/addrbook.json
```

**8. Добавим сиды:**

```
sed -i -e 's|^seeds *=.*|seeds = "211536ab1414b5b9a2a759694902ea619b29c8b1@47.251.14.47:26656,d89e10d917f6f7472125aa4c060c05afa78a9d65@47.251.32.165:26656,bec6934fcddbac139bdecce19f81510cb5e02949@47.254.24.106:26656,32d0e4aec8d8a8e33273337e1821f2fe2309539a@47.88.58.36:26656,1bf5b73f1771ea84f9974b9f0015186f1daa4266@47.251.14.47:26656"|' $HOME/.artelad/config/config.toml
```

**9. Устанавливаем минимальную цену на газ:**

```
sed -i -e 's|^minimum-gas-prices *=.*|minimum-gas-prices = "20000000000uart"|' $HOME/.artelad/config/app.toml
```

**10. Ставим прунинг. Выполним все одной командой:**

```
  sed -i \
  -e 's|^pruning *=.*|pruning = "custom"|' \
  -e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
  -e 's|^pruning-interval *=.*|pruning-interval = "17"|' \
  $HOME/.artelad/config/app.toml
```

**11. Загружаем последний Snap. Выполним команду:**

```
curl "https://snapshots-testnet.nodejumper.io/artela-testnet/artela-testnet_latest.tar.lz4" | lz4 -dc - | tar -xf - -C "$HOME/.artelad"
```

**12. Создаем сервис. Выполним все одной командой:**

```
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
```

**13. Запускаем ноду. Выполним команды по очереди:**

```
sudo systemctl daemon-reload
```
```
sudo systemctl enable artelad.service
```
```
sudo systemctl start artelad.service
```

**14. Давайте проверим логи. Для этого выполните следующую команду и подождите, пока появятся строки с "HEIGHT":**
```
sudo journalctl -u artelad.service -f --no-hostname -o cat
```
![image](https://github.com/Mozgiii9/SetupTheArtelaNode/assets/74683169/28706f01-06e1-4f6e-b2d1-dc824045724f)


**15. Сделаем обновление. Выполните команды по очереди:**
```
sudo systemctl stop artelad
```
```
cd $HOME
```
```
rm -rf artela
```
```
git clone https://github.com/artela-network/artela
```
```
cd artela
```
```
git checkout v0.4.7-rc6
```
```
make install
```
```
sed -E 's/^pool-size[[:space:]]*=[[:space:]]*[0-9]+$/apply-pool-size = 10\nquery-pool-size = 30/' ~/.artelad/config/app.toml > ~/.artelad/config/temp.app.toml && mv ~/.artelad/config/temp.app.toml ~/.artelad/config/app.toml
```
```
sudo systemctl start artelad
```
```
sudo journalctl -u artelad -f --no-hostname -o cat
```

**16. Создадим новый кошелек. Для этого выполните команду:**
```
artelad keys add MyWallet
```

Вместо "MyWallet" введите имя Вашего кошелька БЕЗ кавычек.

Команда автоматически выведет Вам seed фразу и address Вашего кошелька. **Сохраните данные в надежное место.**
![image](https://github.com/Mozgiii9/SetupTheArtelaNode/assets/74683169/23d459ce-d9bc-4021-aeb0-3d3ee4d013b1)


**Для дальнейшей работы ноды нам необходимы тестовые токены, которые можно взять из крана в Дискорде проекта. Но сначала необходимо выполнить следующую команду, чтобы узнать более подробную информацию о кошельке:**
```
artelad debug addr (ваш address)
```
![image](https://github.com/Mozgiii9/SetupTheArtelaNode/assets/74683169/c30645fa-ac05-4115-b989-e2933f4abd01)


Копируем EIP-55 address.

![image](https://github.com/Mozgiii9/SetupTheArtelaNode/assets/74683169/c187b4b1-3073-4273-8a62-ed122a7576aa)


**Идём в [Discord](https://discord.gg/bzru3ReY) проекта, переходим в ветку "#testnet-faucet". Нам нужно запросить тестовые токены. Сделать это можно отправив в чат "$request Ваш адрес EIP-55"**
![image](https://github.com/Mozgiii9/SetupTheArtelaNode/assets/74683169/1f7c24a0-1215-4af0-80ed-b756986557eb)


Бот отправит Вам тестовые токены на указанный Вами кошелек. Подождите примерно минут 5-7 после запроса тестовых токенов, после чего выполните команду для проверки баланса:
```
artelad q bank balances $(artelad keys show Имя_вашего_кошелька -a)
```

### 17. Создадим валидатора. Введем одну большую команду. "moniker", "from" замените на свои значения. Обратите внимание на кавычки:
```
artelad tx staking create-validator \
--amount=1000000uart \
--pubkey=$(artelad tendermint show-validator) \
--moniker="Имя_вашего_кошелька" \
--identity=FFB0AA51A2DF5955 \
--details="-" \
--chain-id=artela_11822-1 \
--commission-rate=0.10 \
--commission-max-rate=0.20 \
--commission-max-change-rate=0.01 \
--min-self-delegation=1 \
--from=Имя_вашего_кошелька \
--gas-prices=0.1uart \
--gas-adjustment=1.5 \
--gas=auto \
-y
```

**18. Теперь делегируем токены самому себе. Для этого выполним команду, в которой заранее необходимо заменить Имя_вашего_кошелька на имя Вашего кошелька:**
```
artelad tx staking delegate $(artelad keys show Имя_вашего_кошелька --bech val -a) 1000000uart --from Имя_вашего_кошелька --chain-id artela_11822-1 --gas-prices 0.1uart --gas-adjustment 1.5 --gas auto -y
```

**19. Далее выполним команду, так же замените Имя_вашего_кошелька на имя Вашего кошелька:**
```
artelad tx staking delegate M0zgiii 1000000uart --from Имя_вашего_кошелька --chain-id artela_11822-1 --gas-prices 0.1uart --gas-adjustment 1.5 --gas auto -y
```

## Отлично! На данном этапе установка ноды Artela подошла к концу. Осталось лишь заполнить форму по [ссылке](https://atkty6pceir.typeform.com/to/o4359Rsd)



### Дополнительные команды:

**Информация о ноде:**

```
artelad status 2>&1 | jq
```

**Посмотреть Sync Status:**
```
artelad status 2>&1 | jq .SyncInfo.catching_up
```

**Остановить ноду:**
```
sudo systemctl stop artelad
```

**Перезагрузить ноду:**
```
sudo systemctl restart artelad
```

**Просмотреть логи:**
```
sudo journalctl -u artelad -f --no-hostname -o cat
```

**Удалить ноду:**
```
sudo systemctl stop artelad && sudo systemctl disable artelad && sudo rm /etc/systemd/system/artelad.service && sudo systemctl daemon-reload && rm -rf $HOME/.artelad && rm -rf artela && sudo rm -rf $(which artelad)
```

**Делегировать токены другому валидатору:**

```
artelad tx staking redelegate $VALOPER_ADDRESS <TO_VALOPER_ADDRESS> 1000000uart --from $WALLET --chain-id artela_11822-1 --gas auto --gas-adjustment 1.5 -y
```

### Обязательно проведите собственный ресерч проектов перед тем как ставить ноду. Сообщество NodeRunner не несет ответственность за Ваши действия и средства. Помните, проводя свой ресёрч, Вы учитесь и развиваетесь.

### Связь со мной: [Telegram(@M0zgiii)](https://t.me/m0zgiii)

### Мои соц. сети: [Twitter](https://twitter.com/m0zgiii) 




