#!/usr/bin/env python3
"""
Envia um pacote do tipo MENSAGEM (ether_type=0x8888) com um token.
O switch só roteia se o token bater com o que foi previamente registrado.

Uso:
    sudo python3 send_message.py [iface] [dst_mac] [--wrong]

    --wrong       envia com chave incorreta (deve ser dropado pelo switch)

Defaults: iface=veth0  dst_mac=00:00:00:00:00:03
"""
import sys
from scapy.all import Ether, sendp
from protocols import Mensagem, PORTS, DEFAULT_KEY, WRONG_KEY


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    use_wrong = "--wrong" in sys.argv

    iface   = args[0] if len(args) > 0 else PORTS["1/0"]["iface"]
    dst_mac = args[1] if len(args) > 1 else PORTS["3/0"]["mac"]
    src_mac = PORTS["1/0"]["mac"]

    key = WRONG_KEY if use_wrong else DEFAULT_KEY
    r1, r2, r3, r4 = key

    pkt = Ether(src=src_mac, dst=dst_mac, type=0x8888) / Mensagem(
        reg1=r1, reg2=r2, reg3=r3, reg4=r4
    )

    label = "CHAVE ERRADA" if use_wrong else "CHAVE CORRETA"
    print(f"[send_message] iface={iface}  dst={dst_mac}  ({label})")
    print(f"  key = {r1:#010x} {r2:#010x} {r3:#010x} {r4:#010x}")
    sendp(pkt, iface=iface, verbose=False)
    expectation = "deve ser DROPADO" if use_wrong else "deve PASSAR"
    print(f"OK: pacote enviado ({expectation})")


if __name__ == "__main__":
    main()
