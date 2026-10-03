Dimensional Modeling — Fogo Cruzado

Pipeline de dados sobre ocorrências de violência armada no Brasil, construído a partir da API pública do Fogo Cruzado. O projeto vai da ingestão bruta até um star schema pronto para análise, passando por uma camada relacional normalizada.

O problema

O Fogo Cruzado mantém a base mais completa de registros de tiroteios em regiões metropolitanas brasileiras, usada por imprensa e por pesquisa em segurança pública. A API entrega os dados como JSON aninhado, paginado e sem estrutura analítica.

O pipeline foi desenhado para responder três perguntas:

A violência armada aumentou ou diminuiu nas capitais cobertas ao longo dos anos?
Como os crimes se distribuem entre os estados, e qual o perfil das vítimas em cada um?
Os motivos registrados variam conforme o local e o período?

Cada pergunta determinou uma escolha de modelagem. A primeira exigiu uma dimensão de tempo com atributos derivados. A segunda forçou um fato no grão de vítima, já que idade e gênero não sobrevivem à agregação por ocorrência. A terceira é resolvida no grão de ocorrência, cruzando motivo, local e data.

Arquitetura
API Fogo Cruzado
      │
      ▼
  raw (JSONB)          Python + psycopg2
      │                payload preservado como veio
      ▼
  core (relacional)    SQL puro, DDL versionado
      │                FK, constraints, 3FN
      ▼
  analytics (estrela)  dbt
                       dim_* e fct_*
Por que uma camada relacional no meio

O caminho mais curto seria ler o JSONB e montar o dimensional direto. A camada core existe por duas razões.

A primeira é de aprendizado: transformar um modelo relacional normalizado em modelo dimensional é o exercício central da modelagem Kimball, e ele só acontece se o relacional existir de fato — com chave estrangeira, constraint e integridade imposta pelo banco.

A segunda é prática: todo o trabalho de achatar e tipar o JSON acontece uma vez, no core. Os modelos do dbt leem tabelas relacionais limpas e cuidam apenas de grão e métrica.

O resultado é uma arquitetura híbrida — core normalizado no espírito de Inmon, marts dimensionais no espírito de Kimball — que é o desenho que a maioria das empresas acaba adotando.

Por que SQL puro no core e dbt nos marts

O dbt materializa modelos via CREATE TABLE AS SELECT: ele derruba e recria a tabela a cada execução. Isso é incompatível com chave estrangeira viva — não dá para manter integridade referencial em tabelas que são dropadas a cada run.

Como o core representa um sistema transacional, ele é construído em SQL puro, com ON CONFLICT explícito garantindo idempotência e FK garantindo consistência. O dbt entra onde brilha: na camada analítica, onde a integridade é verificada por teste depois do fato, não imposta pelo banco antes.

Modelo dimensional

Fatos

Modelo	Grão	Métricas
fct_occurrences	uma linha por ocorrência	contagem de vítimas, contagem de mortos, flag de massacre
fct_victims	uma linha por vítima	idade

Dimensões

dim_date, dim_locations, dim_reason, dim_genre, dim_age_group, dim_situation, dim_person_type.

dim_date e dim_locations são conformadas — servem aos dois fatos, o que permite comparar métricas entre eles na mesma consulta.

dim_locations achata a hierarquia bairro → cidade → estado em uma única tabela. A normalização construída de propósito no core é desfeita de propósito aqui: lá o objetivo era evitar anomalia de atualização, aqui é evitar JOIN na leitura.

As chaves são surrogates geradas com row_number(), exceto dim_date, que usa a própria data no formato YYYYMMDD como inteiro — convenção que mantém a chave legível ao inspecionar o fato.

Qualidade de dados

Ao derivar os limites da dim_date a partir do próprio dado, em vez de fixá-los no código, apareceu uma ocorrência datada de 19 de setembro de 1016 — provável erro de digitação de 2016 na origem.

A consulta ao payload bruto confirmou que o valor vem assim da API, não de erro no cast do pipeline.

O tratamento seguiu o princípio de que dado sujo se isola, não se apaga:

o core preserva o registro como veio da fonte;
os marts filtram registros anteriores a 2016, data em que o Fogo Cruzado começou a operar;
um teste singular no source sinaliza a anomalia com severidade warn, mantendo-a visível sem quebrar a execução.
Testes

Os testes genéricos cobrem unique e not_null nas chaves de todas as dimensões. Nos fatos, testes de relationships verificam que toda chave estrangeira existe na dimensão correspondente — recuperando, por verificação, a integridade referencial que o CREATE TABLE AS SELECT não permite impor.

bash
dbt run
dbt test
Como rodar
bash
# 1. Subir o Postgres (o DDL de raw e core roda na inicialização)
cd ingestion
docker compose up -d

# 2. Ingestão da API
python extract.py

# 3. Carga da camada relacional
psql -f ../transform/03_populate_core.sql

# 4. Modelagem dimensional
cd ../dbt/dimensional_modeling
dbt run
dbt test

Variáveis de ambiente necessárias em .env: credenciais da API do Fogo Cruzado e do Postgres.

Stack

Python, PostgreSQL, dbt, Docker.

Pendências

Rate limit na ingestão. A API responde com HTTP 429 e header Retry-After: 60 após um volume de requisições. A ingestão atual grava cada página assim que a recebe, de modo que uma interrupção não descarta o que já foi coletado, mas ainda falta implementar retry com backoff exponencial para completar a coleta numa única execução.

Benchmark Kimball vs. One Big Table. Comparar o star schema com uma tabela larga equivalente, medindo tempo e I/O no Postgres via EXPLAIN (ANALYZE, BUFFERS) e bytes escaneados no BigQuery. A hipótese é que a estrela vença em banco orientado a linha e perca em banco colunar — e a ideia é medir em vez de supor.

Deploy no GCP. Cloud SQL, Cloud Run para os jobs de ingestão e dbt, Cloud Scheduler para orquestração.