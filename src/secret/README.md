# Header:

O header veio apenas com a struct "ethernet", que é basicamente uma struct que tem como elementos o MAC de destino (para onde você quer enviar), o MAC de origem (de onde você está enviando) e o "ether_type" (que nos diz basicamente qual o tipo de mensagem que quero fazer).

Há 2 tipos de mensagens que nós queremos fazer:

### Mensagem do tipo 1: ***REGISTRAR KEY NO SWITCH=***

Esse tipo de mensagem fala basicamente que nós queremos registrar a key de 16 bytes (128 bits) no switch. Como os registradores têm no máximo 32 bits cada, nós temos que colocar esse número de key em 4 registradores diferentes. Com isso, criamos uma struct "registra_key_h" que contém 4 variáveis de 32 bits, para no secret.p4 guardarmos essas exatas variáveis nos registradores do switch.

### Mensagem do tipo 1: ***MENSAGEM=***

Esse tipo de mensagem fala basicamente que nós queremos enviar uma mensagem para o outro lado do switch. Com isso, se a chave que está nas variáveis da nova struct mensagem_h ser correspondente com a chave que estiver registrada no switch, a mensagem é enviada para o destino, caso contrário, a mensagem é descartada.

### PERGUNTA IMPORTANTE PARA SE FAZER PARA O PROFESSOR: E SE EU NÃO TIVER NENHUMA CHAVE REGISTRADA AINDA NO SWITCH? A MENSAGEM PASSA?

# Parser:

O parser serve basicamente como o próprio nome já diz, para separar a mensagem certinha. Quando você recebe a mensagem, o parser vai separar o pacote que chega em bytes brutos em campos do seu header, como: hdr.ethernet, hdr.rk, hdr.msg.

### Fluxo do parser:

Pacote chega na porta
        ↓
SwitchIngressParser
  → extrai hdr.ethernet
  → olha o ether_type
  → extrai hdr.rk ou hdr.msg
        ↓
SwitchIngress (secret.p4)
  → aqui você toma as decisões
  → gravar token, comparar, dropar...
        ↓
SwitchIngressDeparser
  → remonta o pacote em bytes
        ↓
  (pacote viaja para a porta de saída)
        ↓
SwitchEgressParser
  → lê o pacote de novo
        ↓
SwitchEgress (secret.p4)
  → processamento de saída (vazio no seu caso)
        ↓
SwitchEgressDeparser
  → remonta o pacote final
        ↓
Pacote sai pela porta

