#!/bin/bash
#
# Roteiro de teste manual ponta-a-ponta.
# Rodar DENTRO do container p4studio, depois do switch já estar de pé
# (./start_switch.sh secret).
#
# Abre 2 terminais:
#   Terminal A (sniffer): sudo python3 listen.py veth16 30
#   Terminal B (envios):  bash test_e2e.sh
#

set -e
cd "$(dirname "$0")"

echo "============================================================"
echo " Teste 1: envia mensagem ANTES de registrar a chave"
echo "          (esperado: pacote chega no sniffer? Depende — chave"
echo "           ainda é 0; só passa se 0 também for a chave usada)"
echo "============================================================"
sudo python3 send_message.py
sleep 2

echo
echo "============================================================"
echo " Teste 2: registra a chave no switch"
echo "          (esperado: pacote chega no sniffer)"
echo "============================================================"
sudo python3 send_register_key.py
sleep 2

echo
echo "============================================================"
echo " Teste 3: envia mensagem com chave CORRETA"
echo "          (esperado: pacote chega no sniffer)"
echo "============================================================"
sudo python3 send_message.py
sleep 2

echo
echo "============================================================"
echo " Teste 4: envia mensagem com chave ERRADA"
echo "          (esperado: pacote NÃO chega no sniffer / é dropado)"
echo "============================================================"
sudo python3 send_message.py --wrong
sleep 2

echo
echo "Fim dos envios. Confira os logs do sniffer."
