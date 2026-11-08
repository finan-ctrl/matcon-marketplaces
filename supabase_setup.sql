-- =====================================================================
--  MATCON.casa · Gestão de Marketplaces — estrutura no Supabase
--  Rode este script inteiro no SQL Editor do projeto (uma vez).
-- =====================================================================

-- Cargas (histórico de uploads)
create table if not exists mc_cargas (
  id           bigint generated always as identity primary key,
  tipo         text not null check (tipo in ('base','anymarket')),
  arquivo      text,
  linhas       integer,
  usuario      text,
  criado_em    timestamptz not null default now()
);

-- Base de produtos (já normalizada: preço / 1.000.000, estoque / 10.000, peso em kg)
create table if not exists mc_produtos (
  sku            text primary key,
  name           text,
  ean            text,
  marca          text,
  departamento   text,
  categoria      text,
  subcategoria   text,
  inflamavel     text,
  altura         numeric,
  largura        numeric,
  profundidade   numeric,
  peso           numeric,
  price          numeric,
  special_price  numeric,
  status         text,
  stock          numeric,
  seller_id      text,
  carga_id       bigint references mc_cargas(id) on delete set null,
  atualizado_em  timestamptz not null default now()
);
create index if not exists mc_produtos_carga_idx  on mc_produtos (carga_id);
create index if not exists mc_produtos_seller_idx on mc_produtos (seller_id);

-- Anúncios ativos por marketplace (export Anymarket > Preço)
create table if not exists mc_anuncios (
  id               bigint generated always as identity primary key,
  sku              text not null,
  marketplace      text not null,
  conta            text,
  sku_marketplace  text,
  cod_marketplace  text,
  preco_de         numeric,
  preco_por        numeric,
  custo            numeric,
  calculo_preco    text,
  tipo_listagem    text,
  titulo           text,
  carga_id         bigint references mc_cargas(id) on delete cascade,
  criado_em        timestamptz not null default now()
);
create index if not exists mc_anuncios_sku_idx   on mc_anuncios (sku);
create index if not exists mc_anuncios_carga_idx on mc_anuncios (carga_id);

-- Premissas (regras de elegibilidade, comissões e tabelas de frete) — linha única id = 1
create table if not exists mc_premissas (
  id             integer primary key default 1 check (id = 1),
  dados          jsonb not null,
  usuario        text,
  atualizado_em  timestamptz not null default now()
);

-- Fotografias do resumo (para o gráfico de evolução)
create table if not exists mc_snapshots (
  id         bigint generated always as identity primary key,
  resumo     jsonb not null,
  usuario    text,
  criado_em  timestamptz not null default now()
);

-- Acompanhamento das ações (SKU × marketplace marcado como concluído)
create table if not exists mc_acoes (
  sku            text not null,
  marketplace    text not null,
  acao           text not null,           -- Inativar | Dif | Subir
  concluido      boolean not null default true,
  obs            text,
  usuario        text,
  atualizado_em  timestamptz not null default now(),
  primary key (sku, marketplace)
);

-- ---------------------------------------------------------------------
--  Segurança: só usuários logados (Authentication > Users) acessam
-- ---------------------------------------------------------------------
alter table mc_cargas    enable row level security;
alter table mc_produtos  enable row level security;
alter table mc_anuncios  enable row level security;
alter table mc_premissas enable row level security;
alter table mc_snapshots enable row level security;
alter table mc_acoes     enable row level security;

do $$
declare t text;
begin
  foreach t in array array['mc_cargas','mc_produtos','mc_anuncios','mc_premissas','mc_snapshots','mc_acoes'] loop
    execute format('drop policy if exists "%1$s_auth_all" on %1$s', t);
    execute format('create policy "%1$s_auth_all" on %1$s for all to authenticated using (true) with check (true)', t);
  end loop;
end $$;
