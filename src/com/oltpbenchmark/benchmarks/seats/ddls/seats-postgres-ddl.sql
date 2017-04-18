-- drop tables
drop table if exists config_profile;
drop table if exists config_histograms;
drop table if exists country;
drop table if exists airport;
drop table if exists airport_distance;
drop table if exists airline;
drop table if exists customer;
drop table if exists frequent_flyer;
drop table if exists flight;
drop table if exists reservation;

-- 
-- config_profile
--
create table config_profile (
    cfp_scale_factor            float not null,
    cfp_aiport_max_customer     varchar(10001) not null,
    cfp_flight_start            timestamp not null,
    cfp_flight_upcoming         timestamp not null,
    cfp_flight_past_days        int not null,
    cfp_flight_future_days      int not null,
    cfp_flight_offset           int,
    cfp_reservation_offset      int,
    cfp_num_reservations        bigint not null,
    cfp_code_ids_xrefs          varchar(16004) not null
);

--
-- config_histograms
--
create table config_histograms (
    cfh_name             varchar(128) not null,
    cfh_data             varchar(10005) not null,
    cfh_is_airport       int default 0,
    primary key (cfh_name)
);

-- 
-- country
--
create table country (
    co_id        bigint not null,
    co_name      varchar(64) not null,
    co_code_2    varchar(2) not null,
    co_code_3    varchar(3) not null,
    primary key (co_id)
);

--
-- airport
--
create table airport (
    ap_id          bigint not null,
    ap_code        varchar(3) not null,
    ap_name        varchar(128) not null,
    ap_city        varchar(64) not null,
    ap_postal_code varchar(12),
    ap_co_id       bigint not null references country (co_id),
    ap_longitude   float,
    ap_latitude    float,
    ap_gmt_offset  float,
    ap_wac         bigint,
    ap_iattr00     bigint,
    ap_iattr01     bigint,
    ap_iattr02     bigint,
    ap_iattr03     bigint,
    ap_iattr04     bigint,
    ap_iattr05     bigint,
    ap_iattr06     bigint,
    ap_iattr07     bigint,
    ap_iattr08     bigint,
    ap_iattr09     bigint,
    ap_iattr10     bigint,
    ap_iattr11     bigint,
    ap_iattr12     bigint,
    ap_iattr13     bigint,
    ap_iattr14     bigint,
    ap_iattr15     bigint,
    primary key (ap_id)
);

--
-- airport_distance
--
create table airport_distance (
    d_ap_id0       bigint not null references airport (ap_id),
    d_ap_id1       bigint not null references airport (ap_id),
    d_distance     float not null,
    primary key (d_ap_id0, d_ap_id1)
);

--
-- airline
--
create table airline (
    al_id          bigint not null,
    al_iata_code   varchar(3),
    al_icao_code   varchar(3),
    al_call_sign   varchar(32),
    al_name        varchar(128) not null,
    al_co_id       bigint not null references country (co_id),
    al_iattr00     bigint,
    al_iattr01     bigint,
    al_iattr02     bigint,
    al_iattr03     bigint,
    al_iattr04     bigint,
    al_iattr05     bigint,
    al_iattr06     bigint,
    al_iattr07     bigint,
    al_iattr08     bigint,
    al_iattr09     bigint,
    al_iattr10     bigint,
    al_iattr11     bigint,
    al_iattr12     bigint,
    al_iattr13     bigint,
    al_iattr14     bigint,
    al_iattr15     bigint,
    primary key (al_id)
);

--
-- customer
--
create table customer (
    c_id           bigint not null,
    c_id_str       varchar(64) unique not null,
    c_base_ap_id   bigint references airport (ap_id),
    c_balance      float not null,
    c_sattr00      varchar(32),
    c_sattr01      varchar(8),
    c_sattr02      varchar(8),
    c_sattr03      varchar(8),
    c_sattr04      varchar(8),
    c_sattr05      varchar(8),
    c_sattr06      varchar(8),
    c_sattr07      varchar(8),
    c_sattr08      varchar(8),
    c_sattr09      varchar(8),
    c_sattr10      varchar(8),
    c_sattr11      varchar(8),
    c_sattr12      varchar(8),
    c_sattr13      varchar(8),
    c_sattr14      varchar(8),
    c_sattr15      varchar(8),
    c_sattr16      varchar(8),
    c_sattr17      varchar(8),
    c_sattr18      varchar(8),
    c_sattr19      varchar(8),
    c_iattr00      bigint,
    c_iattr01      bigint,
    c_iattr02      bigint,
    c_iattr03      bigint,
    c_iattr04      bigint,
    c_iattr05      bigint,
    c_iattr06      bigint,
    c_iattr07      bigint,
    c_iattr08      bigint,
    c_iattr09      bigint,
    c_iattr10      bigint,
    c_iattr11      bigint,
    c_iattr12      bigint,
    c_iattr13      bigint,
    c_iattr14      bigint,
    c_iattr15      bigint,
    c_iattr16      bigint,
    c_iattr17      bigint,
    c_iattr18      bigint,
    c_iattr19      bigint,
    primary key (c_id)
);

--
-- frequent_flyer
--
create table frequent_flyer (
    ff_c_id        bigint not null references customer (c_id),
    ff_al_id       bigint not null references airline (al_id),
    ff_c_id_str    varchar(64) not null,
    ff_sattr00     varchar(32),
    ff_sattr01     varchar(32),
    ff_sattr02     varchar(32),
    ff_sattr03     varchar(32),
    ff_iattr00     bigint,
    ff_iattr01     bigint,
    ff_iattr02     bigint,
    ff_iattr03     bigint,
    ff_iattr04     bigint,
    ff_iattr05     bigint,
    ff_iattr06     bigint,
    ff_iattr07     bigint,
    ff_iattr08     bigint,
    ff_iattr09     bigint,
    ff_iattr10     bigint,
    ff_iattr11     bigint,
    ff_iattr12     bigint,
    ff_iattr13     bigint,
    ff_iattr14     bigint,
    ff_iattr15     bigint,
   primary key (ff_c_id, ff_al_id)
);
create index idx_ff_customer_id on frequent_flyer (ff_c_id_str);

--
-- flight
--
create table flight (
    f_id            bigint not null,
    f_al_id         bigint not null references airline (al_id),
    f_depart_ap_id  bigint not null references airport (ap_id),
    f_depart_time   timestamp not null,
    f_arrive_ap_id  bigint not null references airport (ap_id),
    f_arrive_time   timestamp not null,
    f_status        bigint not null,
    f_base_price    float not null,
    f_seats_total   bigint not null,
    f_seats_left    bigint not null,
    f_iattr00       bigint,
    f_iattr01       bigint,
    f_iattr02       bigint,
    f_iattr03       bigint,
    f_iattr04       bigint,
    f_iattr05       bigint,
    f_iattr06       bigint,
    f_iattr07       bigint,
    f_iattr08       bigint,
    f_iattr09       bigint,
    f_iattr10       bigint,
    f_iattr11       bigint,
    f_iattr12       bigint,
    f_iattr13       bigint,
    f_iattr14       bigint,
    f_iattr15       bigint,
    f_iattr16       bigint,
    f_iattr17       bigint,
    f_iattr18       bigint,
    f_iattr19       bigint,
    f_iattr20       bigint,
    f_iattr21       bigint,
    f_iattr22       bigint,
    f_iattr23       bigint,
    f_iattr24       bigint,
    f_iattr25       bigint,
    f_iattr26       bigint,
    f_iattr27       bigint,
    f_iattr28       bigint,
    f_iattr29       bigint,
    primary key (f_id)
);
create index f_depart_time_idx on flight (f_depart_time);

--
-- reservation
--
create table reservation (
    r_id            bigint not null,
    r_c_id          bigint not null references customer (c_id),
    r_f_id          bigint not null references flight (f_id),
    r_seat          bigint not null,
    r_price         float not null,
    r_iattr00       bigint,
    r_iattr01       bigint,
    r_iattr02       bigint,
    r_iattr03       bigint,
    r_iattr04       bigint,
    r_iattr05       bigint,
    r_iattr06       bigint,
    r_iattr07       bigint,
    r_iattr08       bigint,
    unique (r_f_id, r_seat),
    primary key (r_id, r_c_id, r_f_id)
);
