# Scripts de teste

Scripts em scapy para validar o `secret.p4` no simulador Tofino.

## Arquivos

| Arquivo | Função |
|---|---|
| `protocols.py` | Definição scapy dos headers (RegistraKey/Mensagem), portas e chaves de teste |
| `send_register_key.py` | Envia um pacote ether_type=0x9999 pra gravar a chave no switch |
| `send_message.py` | Envia um pacote ether_type=0x8888 (com `--wrong` usa chave errada) |
| `listen.py` | Sniffa numa veth e imprime pacotes do nosso protocolo |
| `test_e2e.sh` | Roteiro de envio que cobre os 4 casos do trabalho |

## Pré-requisitos

Tudo roda **dentro do container** `p4studio`, depois do switch estar de pé:

```bash
docker exec -ti p4studio bash
cd project/simulator && ./start_switch.sh secret   # se ainda não estiver rodando
tmux detach        # ctrl+b d
```

E precisa do scapy instalado (o `setup.sh` raiz já instala via requirements.txt).

## Fluxo de teste

Abra dois terminais dentro do container.

**Terminal A — sniffer na saída (porta 3/0 = veth16):**
```bash
cd project/tests
sudo python3 listen.py veth16 60
```

**Terminal B — envios (entra pela porta 1/0 = veth0):**
```bash
cd project/tests
bash test_e2e.sh
```

Resultado esperado no Terminal A:
1. **Teste 1** (mensagem antes de registrar): pode chegar se a chave guardada (zeros) bater com a enviada — depende. Em geral, deve ser dropado.
2. **Teste 2** (registra chave): chega o pacote `REGISTRA_KEY`.
3. **Teste 3** (mensagem com chave certa): chega o pacote `MENSAGEM`.
4. **Teste 4** (mensagem com chave errada): **não** chega nada.

## Testes individuais

Registrar uma chave:
```bash
sudo python3 send_register_key.py veth0 00:00:00:00:00:03
```

Mandar mensagem com chave certa:
```bash
sudo python3 send_message.py veth0 00:00:00:00:00:03
```

Mandar mensagem com chave errada (deve ser dropada):
```bash
sudo python3 send_message.py veth0 00:00:00:00:00:03 --wrong
```

## Mapeamento portas <-> interfaces

| Porta switch | Interface | MAC |
|---|---|---|
| 1/0 | veth0  | 00:00:00:00:00:01 |
| 2/0 | veth8  | 00:00:00:00:00:02 |
| 3/0 | veth16 | 00:00:00:00:00:03 |
| 4/0 | veth24 | 00:00:00:00:00:04 |

A `forward` table do `setup.py` mapeia destino MAC -> porta de saída, então o
dst_mac do pacote é o que decide por onde ele sai.
