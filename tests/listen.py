#!/usr/bin/env python3
"""
Sniffa pacotes do nosso protocolo (REGISTRA_KEY / MENSAGEM) numa interface.
Útil pra confirmar que o switch encaminhou (ou descartou) o pacote.

Uso:
    sudo python3 listen.py [iface] [timeout_segundos]

Defaults: iface=veth16  timeout=10s
"""
import sys
from scapy.all import sniff, Ether
from protocols import RegistraKey, Mensagem, PORTS


def handle(pkt):
    if pkt.haslayer(RegistraKey):
        rk = pkt[RegistraKey]
        print(f"[REGISTRA_KEY] {pkt[Ether].src} -> {pkt[Ether].dst}  "
              f"key={rk.reg1:#010x} {rk.reg2:#010x} {rk.reg3:#010x} {rk.reg4:#010x}")
    elif pkt.haslayer(Mensagem):
        m = pkt[Mensagem]
        print(f"[MENSAGEM]     {pkt[Ether].src} -> {pkt[Ether].dst}  "
              f"key={m.reg1:#010x} {m.reg2:#010x} {m.reg3:#010x} {m.reg4:#010x}")
    else:
        print(f"[OUTRO] type={pkt[Ether].type:#06x}  {pkt.summary()}")


def main():
    iface   = sys.argv[1] if len(sys.argv) > 1 else PORTS["3/0"]["iface"]
    timeout = int(sys.argv[2]) if len(sys.argv) > 2 else 10

    bpf = "ether proto 0x9999 or ether proto 0x8888"
    print(f"[listen] iface={iface}  timeout={timeout}s  filter='{bpf}'")
    print("Aguardando pacotes...")
    sniff(iface=iface, filter=bpf, prn=handle, timeout=timeout, store=False)
    print("[listen] encerrado")


if __name__ == "__main__":
    main()
