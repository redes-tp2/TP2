"""
Definições scapy dos headers customizados do trabalho.

Ether type 0x9999 -> registra_key_h
Ether type 0x8888 -> mensagem_h

Ambos carregam 4 inteiros de 32 bits (128 bits / 16 bytes = o token).
"""
from scapy.all import Packet, Ether, bind_layers, IntField

ETHERTYPE_REGISTRA_KEY = 0x9999
ETHERTYPE_MENSAGEM = 0x8888


class RegistraKey(Packet):
    name = "RegistraKey"
    fields_desc = [
        IntField("reg1", 0),
        IntField("reg2", 0),
        IntField("reg3", 0),
        IntField("reg4", 0),
    ]


class Mensagem(Packet):
    name = "Mensagem"
    fields_desc = [
        IntField("reg1", 0),
        IntField("reg2", 0),
        IntField("reg3", 0),
        IntField("reg4", 0),
    ]


bind_layers(Ether, RegistraKey, type=ETHERTYPE_REGISTRA_KEY)
bind_layers(Ether, Mensagem, type=ETHERTYPE_MENSAGEM)


# Mapeamento das portas do switch (vem do README do trabalho)
PORTS = {
    "1/0": {"iface": "veth0",  "mac": "00:00:00:00:00:01"},
    "2/0": {"iface": "veth8",  "mac": "00:00:00:00:00:02"},
    "3/0": {"iface": "veth16", "mac": "00:00:00:00:00:03"},
    "4/0": {"iface": "veth24", "mac": "00:00:00:00:00:04"},
}


# Chave default usada nos testes (16 bytes / 4 x 32 bits)
DEFAULT_KEY = (0xDEADBEEF, 0xCAFEBABE, 0x12345678, 0x9ABCDEF0)
WRONG_KEY   = (0x00000000, 0x00000000, 0x00000000, 0x00000000)
