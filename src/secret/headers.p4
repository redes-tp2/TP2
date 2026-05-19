#ifndef _HEADERS_
    #define _HEADERS_

#include <core.p4>
#include <v1model.p4>

#if __TARGET_TOFINO__ == 3
#include <t3na.p4>
#elif __TARGET_TOFINO__ == 2
#include <t2na.p4>
#else
#include <tna.p4>
#endif

#define ETHERTYPE_REGISTRA_KEY 0x9999
#define ETHERTYPE_MENSAGEM 0x8888


typedef bit<48> mac_addr_t;
typedef bit<16> ether_type_t;

header ethernet_h {
    mac_addr_t dst_addr;
    mac_addr_t src_addr;
    bit<16> ether_type;
}

header registra_key_h {
	bit<32> reg1;
	bit<32> reg2;
	bit<32> reg3;
	bit<32> reg4;
}

header mensagem_h {
	bit<32> reg1;
	bit<32> reg2;
	bit<32> reg3;
	bit<32> reg4;
}

struct header_t {
	ethernet_h ethernet;
	registra_key_h rk;
	mensagem_h msg;
}

// Variáveis metadados auxiliares, caso ache necessário utilizá-las
struct metadata_t {
    bit<32> aux1;
    bit<32> aux2;
    bit<32> aux3;
    bit<32> aux4;
    bit<128> aux5;
}

#endif /* _HEADERS_ */
