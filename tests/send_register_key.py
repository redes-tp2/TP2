#!/usr/bin/env python3
"""
Envia um pacote do tipo REGISTRA_KEY (ether_type=0x9999) para gravar
o token de 16 bytes nos registers do switch.

Uso:
    sudo python3 send_register_key.py [iface] [dst_mac]

Defaults: iface=veth0  dst_mac=00:00:00:00:00:03  (entra na porta 1/0, sai pela 3/0)
"""
import sys
from scapy.all import Ether, sendp
from protocols import RegistraKey, PORTS, DEFAULT_KEY


def main():
    iface   = sys.argv[1] if len(sys.argv) > 1 else PORTS["1/0"]["iface"]
    dst_mac = sys.argv[2] if len(sys.argv) > 2 else PORTS["3/0"]["mac"]
    src_mac = PORTS["1/0"]["mac"]

    r1, r2, r3, r4 = DEFAULT_KEY
    pkt = Ether(src=src_mac, dst=dst_mac, type=0x9999) / RegistraKey(
        reg1=r1, reg2=r2, reg3=r3, reg4=r4
    )

    print(f"[send_register_key] iface={iface}  dst={dst_mac}")
    print(f"  key = {r1:#010x} {r2:#010x} {r3:#010x} {r4:#010x}")
    sendp(pkt, iface=iface, verbose=False)
    print("OK: pacote enviado")


if __name__ == "__main__":
    main()
