# MATCON.casa · Gestão de Marketplaces

Painel em HTML (arquivo único) para acompanhar o sortimento da MATCON na Shopee, no Mercado Livre e na Magalu. Os dados ficam no Supabase e o site roda no GitHub Pages.

## Como colocar no ar

1. **Supabase**: crie um projeto, abra o *SQL Editor* e rode o `supabase_setup.sql` inteiro.
2. **Usuários**: em *Authentication › Users › Add user*, crie o login (e-mail e senha) de cada pessoa que vai usar o painel.
3. **Chaves**: em *Project Settings › API*, copie a *Project URL* e a *anon public key* e cole em `SUPABASE_URL` / `SUPABASE_ANON_KEY` no topo do `index.html`. Se deixar em branco, o painel pede a conexão no navegador (botão **Conexão**).
4. **GitHub**: suba o `index.html` num repositório e ative *Settings › Pages › Deploy from branch (main / root)*.

## Uso

- **Cargas**: arraste o .xlsx. O painel reconhece pelos cabeçalhos a aba da **base de produtos** (`sku … seller_id`) e a do **Anymarket › Preço › Exportar** (`SKU INTERNO … MARKETPLACE`). As duas podem estar no mesmo arquivo. Cada carga substitui a anterior e grava uma fotografia do resumo, que alimenta o gráfico de evolução.
- **Visão geral**: o mesmo resumo do Simulador (Ativos / Inativar / Preço diferente / Preço igual / Subir / Final), os motivos de inelegibilidade e a evolução.
- **Shopee / Mercado Livre / Magalu**: lista de ações com filtros e exportação para Excel, e uma caixinha ✓ para marcar cada ação como concluída. A marcação fica gravada e deixa de valer sozinha quando o status do SKU muda.
- **Catálogo**: a elegibilidade por departamento e os motivos de cada SKU.
- **Premissas**: as faixas da Shopee, a tabela de frete do Meli com a reputação, o frete da Magalu e os limites de peso, dimensão, preço e custo. Vale para todo mundo depois de salvar.

## Regras (iguais às do Simulador V9)

**Elegível**: seller = 1, status *Habilitado*, não inflamável, preço > R$ 80, peso < 30 kg e todas as dimensões < 100 cm.

**Custo %**:
- Shopee: (comissão × preço + fixo) ÷ preço
- Meli e Magalu: (comissão × preço + frete) ÷ preço

**Status**:
- *Inativar*: anunciado e não elegível, anunciado com custo acima de 25%, ou anunciado com SKU que não está no catálogo.
- *Preço diferente* / *Preço igual*: anunciado, com o preço do marketplace diferente ou igual ao do site.
- *Subir*: não anunciado, elegível e com custo de até 25%.

**Final** = Preço igual + Subir.

**Normalização da base**: o preço é dividido por 1.000.000 e o estoque por 10.000. Um peso ≥ 1.000 é tratado como a escala ×1.000.000 do export (por exemplo, 1077000 vira 1,077 kg).
