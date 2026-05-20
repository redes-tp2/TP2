#include <core.p4>
#if __TARGET_TOFINO__ == 3
#include <t3na.p4>
#elif __TARGET_TOFINO__ == 2
#include <t2na.p4>
#else
#include <tna.p4>
#endif

#include "headers.p4"
#include "parser.p4"


/* ===================================================== Ingress ===================================================== */


control SwitchIngress(
    /* User */
    inout header_t      hdr,
    inout metadata_t    meta,
    /* Intrinsic */
    in ingress_intrinsic_metadata_t                     ig_intr_md,
    in ingress_intrinsic_metadata_from_parser_t         ig_prsr_md,
    inout ingress_intrinsic_metadata_for_deparser_t     ig_dprsr_md,
    inout ingress_intrinsic_metadata_for_tm_t           ig_tm_md)
{
    /* Forward */
    action hit(PortId_t port) {
        ig_tm_md.ucast_egress_port = port;
    }

    action miss(bit<3> drop) {
        ig_dprsr_md.drop_ctl = drop;
    }

    table forward {
        key = {
            hdr.ethernet.dst_addr : exact;
        }

        actions = {
            hit;
            @defaultonly miss;
        }

        const default_action = miss(0x1);
        size = 1024;
    }

    /* 4 Registers de 32 bits (1 entrada cada) — armazenam a chave de 128 bits */
    Register<bit<32>, bit<1>> (1) secret_values_1;
    Register<bit<32>, bit<1>> (1) secret_values_2;
    Register<bit<32>, bit<1>> (1) secret_values_3;
    Register<bit<32>, bit<1>> (1) secret_values_4;

    /* Ações de ESCRITA: gravam o pedaço da chave que veio no pacote rk */
    RegisterAction<bit<32>, bit<1>, bit<32>>(secret_values_1) write_reg1 = {
        void apply(inout bit<32> value) { value = hdr.rk.reg1; }
    };
    RegisterAction<bit<32>, bit<1>, bit<32>>(secret_values_2) write_reg2 = {
        void apply(inout bit<32> value) { value = hdr.rk.reg2; }
    };
    RegisterAction<bit<32>, bit<1>, bit<32>>(secret_values_3) write_reg3 = {
        void apply(inout bit<32> value) { value = hdr.rk.reg3; }
    };
    RegisterAction<bit<32>, bit<1>, bit<32>>(secret_values_4) write_reg4 = {
        void apply(inout bit<32> value) { value = hdr.rk.reg4; }
    };

    /* Ações de LEITURA: retornam o valor armazenado para comparar com a msg */
    RegisterAction<bit<32>, bit<1>, bit<32>>(secret_values_1) read_reg1 = {
        void apply(inout bit<32> value, out bit<32> rv) { rv = value; }
    };
    RegisterAction<bit<32>, bit<1>, bit<32>>(secret_values_2) read_reg2 = {
        void apply(inout bit<32> value, out bit<32> rv) { rv = value; }
    };
    RegisterAction<bit<32>, bit<1>, bit<32>>(secret_values_3) read_reg3 = {
        void apply(inout bit<32> value, out bit<32> rv) { rv = value; }
    };
    RegisterAction<bit<32>, bit<1>, bit<32>>(secret_values_4) read_reg4 = {
        void apply(inout bit<32> value, out bit<32> rv) { rv = value; }
    };


    apply {
        /* Realiza roteamento MAC. Não excluir */
        forward.apply();

        if (hdr.rk.isValid()) {
            /* ETHERTYPE_REGISTRA_KEY (0x9999): grava a chave nos 4 Registers */
            write_reg1.execute(0);
            write_reg2.execute(0);
            write_reg3.execute(0);
            write_reg4.execute(0);
        }
        else if (hdr.msg.isValid()) {
            /* ETHERTYPE_MENSAGEM (0x8888): lê chave armazenada e compara com a msg */
            meta.aux1 = read_reg1.execute(0);
            meta.aux2 = read_reg2.execute(0);
            meta.aux3 = read_reg3.execute(0);
            meta.aux4 = read_reg4.execute(0);

            if (meta.aux1 != hdr.msg.reg1 ||
                meta.aux2 != hdr.msg.reg2 ||
                meta.aux3 != hdr.msg.reg3 ||
                meta.aux4 != hdr.msg.reg4) {
                ig_dprsr_md.drop_ctl = 1;   /* chave errada -> dropa */
            }
            /* chave correta -> não faz nada, forward.apply() já setou a porta */
        }
    }
}

/* ===================================================== Egress ===================================================== */

control SwitchEgress(
    /* User */
    inout header_t      hdr,
    inout metadata_t    meta,
    /* Intrinsic */
    in egress_intrinsic_metadata_t                      eg_intr_md,
    in egress_intrinsic_metadata_from_parser_t          eg_prsr_md,
    inout egress_intrinsic_metadata_for_deparser_t      eg_dprsr_md,
    inout egress_intrinsic_metadata_for_output_port_t   eg_oport_md)
{
    apply {}
}


/* ===================================================== Final Pipeline ===================================================== */
Pipeline(
    SwitchIngressParser(),
    SwitchIngress(),
    SwitchIngressDeparser(),
    SwitchEgressParser(),
    SwitchEgress(),
    SwitchEgressDeparser()
) pipe;

Switch(pipe) main;
