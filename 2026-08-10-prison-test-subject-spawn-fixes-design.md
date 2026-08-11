# Especificação: correções de spawn no Prison Challenge e The Test Subject

## Contexto

Dois problemas foram reportados nos cenários da versão Build 42.20:

1. O **Prison Challenge** inicia normalmente e entrega ao personagem o uniforme de prisioneiro e uma ferramenta, mas a prisão não contém zumbis.
2. No **The Test Subject**, zumbis já eliminados voltam a aparecer depois que o jogador fecha e continua a partida. O caso confirmado ocorreu na cafeteria.

## Objetivos

- Fazer o spawn inicial do Prison Challenge ocorrer de maneira confiável na Build 42.20.
- Impedir que o carregamento de um save reinicialize eventos de spawn já concluídos.
- Preservar os parâmetros de dificuldade e a probabilidade aleatória por cela pretendida pelo cenário.
- Manter compatibilidade com saves existentes sempre que os dados persistidos ainda estiverem disponíveis.
- Fazer mudanças pequenas e restritas aos dois cenários.

## Fora de escopo

- Correção ou alteração do preset sandbox `pillow`.
- Refatoração genérica de todos os cenários.
- Mudança deliberada de balanceamento, quantidade ou distribuição de zumbis fora da correção da geometria inválida atual.
- Alteração dos equipamentos iniciais do jogador.
- Mudança do sistema global de registro de challenges, salvo se um teste demonstrar que ela é necessária para estes dois defeitos.

## Arquivos afetados

- `Contents/mods/Peri's Random Scenarios/42/media/lua/client/LastStand/PrisonChallenge.lua`
- `Contents/mods/Peri's Random Scenarios/42/media/lua/client/LastStand/TheTestSubject.lua`

## Diagnóstico consolidado

### Prison Challenge

O recebimento do uniforme e da ferramenta comprova que `PrisonChallenge.OnNewGame()` está sendo executado. Portanto, a ausência de zumbis não é causada pela falta de execução completa do callback de início.

O problema está no caminho específico de spawn:

- `SpawnZombiesInCells()` é chamado imediatamente durante a inicialização.
- A função tenta criar zumbis em várias coordenadas sem confirmar que os respectivos `IsoGridSquare` estão carregados.
- A Build 42 pode ainda não ter carregado todas as áreas da prisão nesse momento.
- O outfit é passado como `Inmate`, uma variável global não definida, embora `addZombiesInOutfit` espere o nome do outfit como string.
- Existe um registro para `PrisonChallenge.DireCheck`, mas essa função não existe. A função implementada é `PrisonChallenge.DifficultyCheck` e já é chamada por `OnNewGame`.
- `DifficultyCheck()` redefine marcadores como `diningroomseen`, `breakroomseen` e `mainentranceseen` em cada carregamento, o que pode provocar respawns futuros.

A aleatoriedade não explica uma prisão completamente vazia: o algoritmo executa tentativas suficientes para que zero spawns em todas as celas seja extremamente improvável.

Ainda deve ser confirmado no jogo se as coordenadas atuais correspondem a pisos válidos das celas na Build 42.20. A correção não deve considerar coordenadas antigas como válidas sem essa verificação.

Há uma hipótese adicional forte: as posições de spawn do jogador na prisão já precisaram ser alteradas porque a geometria do mapa mudou, mas os pontos de spawn de zumbis permanecem absolutos e antigos. Se a prisão foi deslocada ou redesenhada, o script pode estar tentando gerar zumbis fora da prisão atual. Isso explica o uniforme e a ferramenta funcionarem, mas a população específica do cenário não aparecer. A hipótese precisa ser confirmada pela fase de diagnóstico; não é uma causa comprovada ainda.

Inventário das coordenadas absolutas atuais da Prison:

- celas: `x=7682` e `x=7696`; bloco sul de `y=11943` até `y=11907`; bloco norte de `y=11855` até `y=11817`; andares `z=0` e `z=1`;
- refeitório: `7647, 11877, 0`;
- sala de descanso: `7659, 11847, 0`;
- recreação externa: `7640, 11918, 0`;
- estacionamento: `7615, 11782, 0`;
- entrada principal: `7722, 11884, 0`.

### The Test Subject

A causa do respawn está confirmada. `TheTestSubject.OnNewGame()` atribui `false` a todos os marcadores de áreas sempre que a partida é carregada, antes de verificar o tempo sobrevivido.

Ao continuar um save, `pillowmod.cafeteriadone` volta de `true` para `false`. No evento periódico seguinte, a coordenada da cafeteria está carregada e o script cria novamente os oito zumbis previstos para essa área.

Também existem quatro verificações incorretas:

- `dorm1done`
- `dorm2done`
- `dorm3done`
- `dorm4done`

Essas condições consultam variáveis globais, enquanto os valores são armazenados em `pillowmod`. Como resultado, os dormitórios não são marcados corretamente pelo fluxo esperado e a rotina de eventos não consegue concluir naturalmente todos os seus estados.

## Design da correção

### 1. Estado persistente e idempotência

Os marcadores de spawn devem ser inicializados somente quando ainda forem `nil`. Valores `true` ou `false` já existentes no `ModData` nunca devem ser sobrescritos durante o carregamento.

O padrão esperado é equivalente a:

```lua
if pillowmod.cafeteriadone == nil then
    pillowmod.cafeteriadone = false
end
```

Não se deve usar apenas `getHoursSurvived() <= 1` como identificação de jogo novo. Um jogador pode salvar e carregar durante a primeira hora, causando novamente a reinicialização indevida.

Para reduzir repetição no The Test Subject, os nomes dos marcadores podem ser percorridos por uma tabela local. Essa tabela deve permanecer no próprio arquivo do cenário; não é necessário criar um módulo compartilhado.

Marcadores existentes em saves antigos devem ser preservados:

- `true`: a área já disparou e não pode gerar zumbis novamente.
- `false`: a área ainda está pendente.
- `nil`: campo inexistente; inicializar como `false`.

### 2. Correção do The Test Subject

As atribuições incondicionais de `false` no começo de `OnNewGame()` serão substituídas por inicialização condicional baseada em `nil`.

As condições dos dormitórios passarão a consultar:

```lua
pillowmod.dorm1done
pillowmod.dorm2done
pillowmod.dorm3done
pillowmod.dorm4done
```

Cada marcador continuará sendo alterado para `true` somente após a chamada de spawn da respectiva área. O evento `EveryTenMinutes` continuará sendo removido quando todos os marcadores estiverem concluídos, preservando o limite adicional de 24 horas já existente.

Não serão alteradas as quantidades, coordenadas ou roupas dos zumbis do cenário neste trabalho.

### 3. Correção do Prison Challenge

A correção será feita em duas etapas: validação das coordenadas e spawn adiado/idempotente.

#### 3.1 Fase de investigação e validação das coordenadas

Antes da alteração definitiva, devem ser registrados no log:

- coordenadas atuais do jogador;
- existência do `IsoGridSquare` usado em cada bloco da prisão;
- início e fim de cada tentativa de spawn;
- quantidade de pontos válidos e inválidos encontrada.

Esta fase é um pré-requisito explícito da correção funcional. Primeiro será criada uma versão somente com diagnóstico, sem mudar a população. Ela será executada nas oito posições iniciais existentes no cenário e produzirá uma lista fechada de pontos de piso válidos para os blocos norte e sul.

Os pontos usados para spawn devem ser conferidos na Build 42.20. Coordenadas que correspondam a parede, objeto sólido ou área removida devem ser substituídas por pisos caminháveis dentro das celas. A lista e a contagem resultantes por bloco serão registradas no plano/resultado da implementação e confirmadas pelo responsável pelo mod antes da substituição das coordenadas. A correção funcional não deverá avançar com coordenadas presumidas.

O conjunto de coordenadas válidas deve ser representado explicitamente e dividido por bloco norte/sul. O comentário atual informa que existe uma nova cela a cada três quadrados, que há 104 celas no total, mas o laço atual percorre cada valor de `y` e usa uma única rolagem para os dois andares. Para eliminar essa contradição, a referência de balanceamento será a intenção documentada de uma tentativa por cela real:

- cada cela validada fornecerá exatamente um ponto elegível de spawn;
- cada ponto fará uma rolagem independente usando a condição atual `ZombRand(pillowmod.spawnincellchance) + 1 == 1`;
- uma rolagem bem-sucedida criará exatamente um zumbi naquele ponto;
- os valores de `spawnincellchance` definidos pelas dificuldades Normal, Dire e Brutal não serão alterados;
- se a Build 42.20 ainda tiver as 104 celas descritas, existirão 104 pontos elegíveis;
- se a geometria atual tiver outra quantidade de celas, a lista deverá conter todas as celas reais encontradas e a quantidade divergente deverá ser confirmada pelo responsável pelo mod no gate da fase 3.1.

Assim, a probabilidade por cela é preservada e o resultado deixa de depender de tentativas sobre paredes ou da correlação artificial entre os andares. A população total pode diferir da execução bruta atual, pois o algoritmo atual faz 152 rolagens e pode criar dois zumbis por sucesso, inclusive em pontos que não representam uma cela; essa diferença é tratada como correção da geometria/algoritmo inválido, não como ajuste intencional de balanceamento.

#### 3.2 Spawn adiado e executado uma única vez

O cenário fará uma tentativa inicial em `OnNewGame()`. Se os quadrados necessários ainda não estiverem carregados, o spawn não será considerado concluído e será tentado novamente pelo callback periódico já existente.

Para evitar duplicação:

- serão reaproveitados os marcadores persistentes já existentes `northcellblock` e `southcellblock`, eliminando a necessidade de migrar nomes;
- esses marcadores serão inicializados somente quando forem `nil` e não serão mais redefinidos por `DifficultyCheck()`;
- antes de qualquer spawn, todos os pontos configurados para o bloco serão pré-validados;
- se qualquer ponto retornar `nil`, o bloco inteiro será adiado sem criar nenhum zumbi e sem mudar seu marcador;
- como a fase 3.1 garante que a configuração contém apenas pisos válidos, `nil` em tempo de execução será tratado exclusivamente como área ainda não carregada;
- depois de processado, seu marcador será definido como `true`;
- carregamentos posteriores respeitarão os marcadores existentes;
- um bloco concluído nunca será processado novamente.

Dividir o estado por bloco evita exigir que toda a prisão esteja carregada ao mesmo tempo e evita duplicar zumbis em uma parte já processada.

O processamento de cada bloco será atômico do ponto de vista do script: ou todos os pontos configurados estão carregados e o bloco é processado, ou nenhum spawn é tentado. Isso impede que uma tentativa parcial seja repetida e duplique zumbis.

O outfit será passado como string:

```lua
addZombiesInOutfit(x, y, z, count, "Inmate", 0)
```

O registro abaixo será removido, pois aponta para uma função inexistente e a verificação de dificuldade já ocorre em `OnNewGame()`:

```lua
Events.OnCreatePlayer.Add(PrisonChallenge.DireCheck)
```

Os marcadores de hordas adicionais (`diningroomseen`, `breakroomseen`, `outdoorrecseen`, `parkinglotseen` e `mainentranceseen`) também passarão a ser inicializados somente quando forem `nil`.

## Auditoria posterior: outros cenários com coordenadas fixas

Esta seção é uma lista de verificação, não amplia a implementação atual. Nenhum dos arquivos abaixo será alterado como parte desta correção, a menos que uma nova análise e aprovação definam esse escopo.

Mudanças de geometria ou deslocamento de prédios no mapa podem causar os mesmos sintomas da Prison: o jogador inicia corretamente, mas as hordas aparecem fora do local esperado ou não aparecem. Os cenários a verificar são:

### The Test Subject

Possui spawns absolutos em toda a instalação subterrânea:

- início: `5674, 12458, -17`;
- cavernas: `5671, 12445, -17` e `5628, 12462, -17`;
- segurança: `5581, 12470, -17`;
- morgue: `5569, 12438, -17`;
- cirurgia: `5563, 12421, -16`;
- arsenal: `5562, 12448, -16`;
- cafeteria: `5568, 12474, -15`;
- sala de controle: `5543, 12476, -15`;
- dormitórios: `5565, 12475, -14`, `5558, 12496, -14`, `5560, 12496, -13` e `5578, 12499, -13`;
- escadaria: `5543, 12466, -13`;
- lobby/superfície: `5579, 12482, 0`.

### Fire Sale

Possui hordas fixas nas entradas e saídas do shopping:

- entradas principais: `13913, 5730, 0`, `13935, 5921, 0`, `13950, 5921, 0`, `13863, 5821, 0` e `13863, 5834, 0`;
- utilitários e saídas: `13870, 5789, 0`, `13867, 5889, 0`, `13888, 5894, 0`, `14003, 5832, 0`, `14002, 5805, 0` e `13960, 5755, 0`.

Além dos zumbis, o cenário remove grades e manipula objetos em coordenadas fixas do shopping. A validação deve confirmar tanto as posições das hordas quanto os acessos/saídas.

### Last Ditch Security

Cria hordas com origem fixa e destino na posição atual do jogador. As origens são:

- escadas sul: `10067, 12666`;
- entrada principal: `10081, 12641`;
- escadas leste: `10123, 12630`;
- ala leste: `10088, 12610`;
- ala oeste: `10046, 12632`.

Cada origem recebe variações positivas e negativas, controladas por `spawnvariance`. O cenário também remove escadas nas coordenadas `x=10061..10063, y=12665, z=0` e `x=10122, y=12623..12625, z=0`; por isso deve ser validado mesmo que as hordas aparentem funcionar.

### Cenários sem spawn absoluto de zumbis identificado

- Hospital Challenge: spawn relativo à posição do jogador (`pl:getX() + 12`, `pl:getY() + 12`).
- Abandoned Soldier: origem das hordas calculada a partir da posição atual do jogador.
- Naked and Afraid, The Last Flight, Dodgeball of the Dead e Entering Knox Country: não têm chamadas de spawn de zumbis no código atual.

## Procedimento de verificação futura dos cenários auditados

Para cada cenário da auditoria:

1. iniciar um jogo novo e registrar a posição inicial do jogador;
2. verificar cada coordenada fixa no mapa da Build 42.20;
3. confirmar que o quadrado existe e pertence à área pretendida;
4. acionar o evento de spawn e confirmar a presença da horda no local esperado;
5. registrar coordenadas substituídas, se houver, antes de qualquer alteração de código.

## Tratamento de erros e observabilidade

O código deverá evitar acesso a jogador ou quadrado inexistente durante os callbacks. Quando uma área ainda não estiver carregada, a função retornará sem marcar o respectivo bloco como concluído.

Os logs de diagnóstico devem identificar o cenário e a região, por exemplo:

```text
[PrisonChallenge] north block not loaded; spawn postponed
[PrisonChallenge] north block spawn completed
```

Logs muito detalhados por coordenada podem ser mantidos apenas durante a validação. A versão final deve registrar somente o primeiro adiamento de cada bloco, a conclusão e erros relevantes. Áreas já processadas não devem gerar uma mensagem a cada callback periódico.

## Compatibilidade de saves

### The Test Subject

Saves que ainda contenham marcadores `true` serão preservados e não deverão gerar novamente as áreas concluídas. Campos ausentes serão tratados como áreas ainda não processadas.

Se um save já tiver sido carregado pela versão defeituosa e salvo novamente com algum marcador indevidamente em `false`, não há informação suficiente para distinguir esse estado de uma área legitimamente pendente. Esses casos podem ter um último respawn após a atualização.

### Prison Challenge

Os marcadores `northcellblock` e `southcellblock` já existem no cenário, mas a versão atual os redefine como `false` em cada carregamento e não os utiliza para controlar o spawn. Depois da correção, eles serão preservados e passarão a representar a conclusão dos respectivos blocos.

Em saves anteriores, esses valores podem estar ausentes ou em `false`. Nesses casos, os blocos serão considerados pendentes e poderão gerar zumbis ao carregar o save antigo.

Para evitar uma migração complexa sem dados confiáveis, a correção será garantida principalmente para novos jogos. O comportamento em saves antigos deverá ser comunicado nas notas da versão.

## Alternativas consideradas

### A. Executar o spawn apenas em `OnNewGame`

Mudança menor, porém continua dependendo do momento exato em que os chunks são carregados. Não é recomendada.

### B. Atrasar todo o spawn usando apenas um marcador global

É simples, mas exige toda a prisão carregada simultaneamente ou corre risco de marcar como concluído um spawn parcial. Não é recomendada.

### C. Spawn adiado com marcadores por bloco — recomendada

Mantém a implementação pequena, tolera carregamento parcial do mapa e garante idempotência por região.

### D. Criar uma infraestrutura genérica de eventos para todos os cenários

Poderia reduzir duplicação no futuro, mas ampliaria muito o escopo e o risco desta correção. Não será feito agora.

## Plano de testes

### Testes estáticos/unitários

Caso o projeto adote um executor Lua ou harness de testes, cobrir:

- inicialização de campo `nil` como `false`;
- preservação de campo `true` após carregamento;
- preservação de campo `false` após carregamento;
- não execução de bloco da prisão quando qualquer ponto configurado retornar `nil`;
- ausência de spawn parcial quando qualquer ponto do bloco retornar `nil`;
- execução única quando o bloco estiver carregado;
- ausência de segunda execução quando o marcador estiver `true`;
- uso de `pillowmod.dormNdone` nas quatro condições.

### Testes manuais obrigatórios

#### Prison Challenge

1. Executar a fase de diagnóstico de maneira determinística nas oito posições iniciais configuradas no cenário, usando seleção controlada durante o teste em vez de depender do sorteio.
2. Confirmar e registrar os pontos válidos dos blocos norte e sul antes da correção funcional.
3. Criar um jogo novo em cada uma das oito posições e confirmar uniforme, ferramenta e zumbis nas celas.
4. Confirmar no log a conclusão dos blocos norte e sul.
5. Simular um bloco ainda não carregado e confirmar que nenhum spawn parcial ocorre.
6. Salvar e continuar a partida antes de uma hora sobrevivida.
7. Confirmar que os blocos não recebem uma segunda população.
8. Sair da prisão e retornar para confirmar que hordas adicionais não são repetidas.
9. Executar a matriz das oito posições ao menos em Normal; repetir a verificação de quantidade e conclusão dos blocos em Always Dire e Always Brutal.
10. Registrar os logs e resultados da matriz manual como evidência da validação.

#### The Test Subject

1. Criar um jogo novo e acionar o spawn da cafeteria.
2. Eliminar os zumbis da cafeteria.
3. Salvar, fechar e continuar a partida no mesmo local.
4. Aguardar mais de dez minutos no jogo e confirmar que nenhum zumbi reaparece na cafeteria.
5. Repetir o carregamento durante a primeira hora sobrevivida.
6. Confirmar que uma área ainda não visitada continua gerando seus zumbis normalmente.
7. Visitar os quatro dormitórios e confirmar que seus marcadores são concluídos.
8. Confirmar que os callbacks periódicos são removidos quando todos os eventos terminam ou após o limite de 24 horas.

## Critérios de aceite

- Um novo Prison Challenge apresenta zumbis nas celas em todas as posições iniciais válidas testadas.
- Nenhum bloco de celas é populado mais de uma vez no mesmo save.
- O console não apresenta erro relacionado a `PrisonChallenge.DireCheck` ou ao outfit `Inmate`.
- Continuar um save do The Test Subject não redefine marcadores já concluídos.
- A cafeteria não recebe novos zumbis depois de limpa e após o carregamento do save.
- Áreas ainda pendentes continuam funcionando normalmente.
- Os quatro dormitórios usam e atualizam os respectivos campos em `pillowmod`.
- O preset `pillow` e os demais cenários permanecem inalterados por este trabalho.
