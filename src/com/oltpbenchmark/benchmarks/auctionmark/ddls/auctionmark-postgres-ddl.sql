/***************************************************************************
 *  copyright (c) 2010 by h-store project                                  *
 *  brown university                                                       *
 *  massachusetts institute of technology                                  *
 *  yale university                                                        *
 *                                                                         *
 *  andy pavlo (pavlo@cs.brown.edu)                                        *
 *  http://www.cs.brown.edu/~pavlo/                                        *
 *                                                                         *
 *  visawee angkanawaraphan (visawee@cs.brown.edu)                         *
 *  http://www.cs.brown.edu/~visawee/                                      *
 *                                                                         *
 *  permission is hereby granted, free of charge, to any person obtaining  *
 *  a copy of this software and associated documentation files (the        *
 *  "software"), to deal in the software without restriction, including    *
 *  without limitation the rights to use, copy, modify, merge, publish,    *
 *  distribute, sublicense, and/or sell copies of the software, and to     *
 *  permit persons to whom the software is furnished to do so, subject to  *
 *  the following conditions:                                              *
 *                                                                         *
 *  the above copyright notice and this permission notice shall be         *
 *  included in all copies or substantial portions of the software.        *
 *                                                                         *
 *  the software is provided "as is", without warranty of any kind,        *
 *  express or implied, including but not limited to the warranties of     *
 *  merchantability, fitness for a particular purpose and noninfringement. *
 *  in no event shall the authors be liable for any claim, damages or      *
 *  other liability, whether in an action of contract, tort or otherwise,  *
 *  arising from, out of or in connection with the software or the use or  *
 *  other dealings in the software.                                        *
 ***************************************************************************/

-- ================================================================ 
-- config_profile
-- ================================================================
drop table if exists config_profile cascade;
create table config_profile (
    cfp_scale_factor            float not null,
    cfp_loader_start            timestamp not null,
    cfp_loader_stop             timestamp not null,
    cfp_user_item_histogram     varchar(12000) not null
);

-- ================================================================
-- region
-- represents regions of users
-- r_id             region's id
-- r_name           region's name
-- ================================================================
drop table if exists region cascade;
create table region (
    r_id                bigint not null,
    r_name              varchar(32),
    primary key (r_id)
);

-- ================================================================
-- useracct
-- represents user accounts 
-- u_id             user id
-- u_firstname      user's first name
-- u_lastname       user's last name
-- u_password       user's password
-- u_email          user's email
-- u_rating         user's rating as a seller
-- u_balance        user's balance
-- u_created        user's create date
-- u_r_id           user's region id
-- ================================================================
drop table if exists useracct cascade;
create table useracct (
    u_id                bigint not null,
    u_rating            bigint not null,
    u_balance           float not null,
    u_comments          integer default 0,
    u_r_id              bigint not null references region (r_id),
    u_created           timestamp,
    u_updated           timestamp,
    u_sattr0            varchar(64),
    u_sattr1            varchar(64),
    u_sattr2            varchar(64),
    u_sattr3            varchar(64),
    u_sattr4            varchar(64),
    u_sattr5            varchar(64),
    u_sattr6            varchar(64),
    u_sattr7            varchar(64),
    u_iattr0            bigint default null,
    u_iattr1            bigint default null,
    u_iattr2            bigint default null,
    u_iattr3            bigint default null,
    u_iattr4            bigint default null,
    u_iattr5            bigint default null,
    u_iattr6            bigint default null,
    u_iattr7            bigint default null, 
    primary key (u_id)
);
create index idx_useracct_region on useracct (u_id, u_r_id);

-- ================================================================
-- useracct_attributes
-- represents user's attributes 
-- ================================================================
drop table if exists useracct_attributes cascade;
create table useracct_attributes (
    ua_id               bigint not null,
    ua_u_id             bigint not null references useracct (u_id),
    ua_name             varchar(32) not null,
    ua_value            varchar(32) not null,
    u_created           timestamp,
    primary key (ua_id, ua_u_id)
);

-- ================================================================
-- category
-- represents merchandises' categories. category can be hierarchical aligned using c_parent_id.
-- c_id                category's id
-- c_name            category's name
-- c_parent_id        parent category's id
-- ================================================================
drop table if exists category cascade;
create table category (
    c_id                bigint not null,
    c_name              varchar(50),
    c_parent_id         bigint references category (c_id),
    primary key (c_id)
);
create index idx_category_parent on category (c_parent_id);

-- ================================================================
-- global_attribute_group
-- represents merchandises' global attribute groups (for example, brand, material, feature etc.).
-- gag_id            global attribute group's id
-- gag_c_id            associated category's id
-- gag_name            global attribute group's name
-- ================================================================
drop table if exists global_attribute_group cascade;
create table global_attribute_group (
    gag_id              bigint not null,
    gag_c_id            bigint not null references category (c_id),
    gag_name            varchar(100) not null,
    primary key (gag_id)
);

-- ================================================================
-- global_attribute_value
-- represents merchandises' global attributes within each attribute
-- groups (for example, rolex, casio, seiko within brand)
-- gav_id            global attribute value's id
-- gav_gag_id        associated global attribute group's id
-- gav_name            global attribute value's name
-- ================================================================
drop table if exists global_attribute_value cascade;
create table global_attribute_value (
    gav_id              bigint not null,
    gav_gag_id          bigint not null references global_attribute_group (gag_id),
    gav_name            varchar(100) not null,
    primary key (gav_id, gav_gag_id)
);

-- ================================================================
-- item
-- represents merchandises
-- i_id                  item's id
-- i_u_id                seller's id
-- i_c_id                category's id
-- i_name                item's name
-- i_description      item's description
-- i_initial_price    item's initial price
-- i_reserve_price    item's reserve price
-- i_buy_now            item's buy now price
-- i_nb_of_bids        item's number of bids
-- i_max_bid            item's max bid price
-- i_user_attributes text field for attributes defined just for this item
-- i_start_date        item's bid start date
-- i_end_date          item's bid end date
-- i_status            items' status (0 = open, 1 = wait for purchase, 2 = close)
-- ================================================================
drop table if exists item cascade;
create table item (
    i_id                bigint not null,
    i_u_id              bigint not null references useracct (u_id),
    i_c_id              bigint not null references category (c_id),
    i_name              varchar(100),
    i_description       varchar(1024),
    i_user_attributes   varchar(255) default null,
    i_initial_price     float not null,
    i_current_price     float not null,
    i_num_bids          bigint,
    i_num_images        bigint,
    i_num_global_attrs  bigint,
    i_num_comments      bigint,
    i_start_date        timestamp,
    i_end_date          timestamp,
    i_status            int default 0,
    i_created           timestamp,
    i_updated           timestamp,
    i_iattr0            bigint default null,
    i_iattr1            bigint default null,
    i_iattr2            bigint default null,
    i_iattr3            bigint default null,
    i_iattr4            bigint default null,
    i_iattr5            bigint default null,
    i_iattr6            bigint default null,
    i_iattr7            bigint default null, 
    primary key (i_id, i_u_id)
);
create index idx_item_seller on item (i_u_id);

-- ================================================================
-- item_attribute
-- represents mappings between attribute values and items
-- ia_id            item attribute's id
-- ia_i_id            item's id
-- ia_gav_id        global attribute value's id
-- ================================================================
drop table if exists item_attribute cascade;
create table item_attribute (
    ia_id               bigint not null,
    ia_i_id             bigint not null,
    ia_u_id             bigint not null,
    ia_gav_id           bigint not null,
    ia_gag_id           bigint not null,
    ia_sattr0           varchar(64) default null,
    foreign key (ia_i_id, ia_u_id) references item (i_id, i_u_id) on delete cascade,
    foreign key (ia_gav_id, ia_gag_id) references global_attribute_value (gav_id, gav_gag_id),
    primary key (ia_id, ia_i_id, ia_u_id)
);

-- ================================================================
-- item_image
-- represents images of items
-- ii_id            image's id
-- ii_i_id            item's id
-- ii_path            image's path
-- ================================================================
drop table if exists item_image cascade;
create table item_image (
    ii_id               bigint not null,
    ii_i_id             bigint not null,
    ii_u_id             bigint not null,
    ii_sattr0            varchar(128) not null,
    foreign key (ii_i_id, ii_u_id) references item (i_id, i_u_id) on delete cascade,
    primary key (ii_id, ii_i_id, ii_u_id)
);

-- ================================================================
-- item_comment
-- represents comments provided by buyers
-- ic_id            comment's id
-- ic_i_id            item's id
-- ic_u_id            buyer's id
-- ic_date            comment's create date
-- ic_question        comment by buyer
-- ic_response        response from seller
-- ================================================================
drop table if exists item_comment cascade;
create table item_comment (
    ic_id               bigint not null,
    ic_i_id             bigint not null,
    ic_u_id             bigint not null,
    ic_buyer_id         bigint not null references useracct (u_id),
    ic_question         varchar(128) not null,
    ic_response         varchar(128) default null,
    ic_created          timestamp,
    ic_updated          timestamp,
    foreign key (ic_i_id, ic_u_id) references item (i_id, i_u_id) on delete cascade,
    primary key (ic_id, ic_i_id, ic_u_id)
); 
-- create index idx_item_comment on item_comment (ic_i_id, ic_u_id);

-- ================================================================
-- item_bid
-- represents merchandises' bids
-- ib_id            bid's id
-- ib_i_id            item's id
-- ib_u_id            buyer's id
-- ib_type            type of transaction (bid or buy_now)
-- ib_bid            bid's price
-- ib_max_bid        ???
-- ib_date            bid's date
-- ================================================================
drop table if exists item_bid cascade;
create table item_bid (
    ib_id               bigint not null,
    ib_i_id             bigint not null,
    ib_u_id             bigint not null,
    ib_buyer_id         bigint not null references useracct (u_id),
    ib_bid                float not null,
    ib_max_bid          float not null,
    ib_created          timestamp,
    ib_updated          timestamp,
    foreign key (ib_i_id, ib_u_id) references item (i_id, i_u_id) on delete cascade,
    primary key (ib_id, ib_i_id, ib_u_id)
);

-- ================================================================
-- item_max_bid
-- cross-reference table to the current max bid for an auction
-- ================================================================
drop table if exists item_max_bid cascade;
create table item_max_bid (
    imb_i_id            bigint not null,
    imb_u_id            bigint not null,
    imb_ib_id           bigint not null,
    imb_ib_i_id         bigint not null,
    imb_ib_u_id         bigint not null,
    imb_created         timestamp,
    imb_updated         timestamp,
    foreign key (imb_i_id, imb_u_id) references item (i_id, i_u_id) on delete cascade,
    foreign key (imb_ib_id, imb_ib_i_id, imb_ib_u_id) references item_bid (ib_id, ib_i_id, ib_u_id) on delete cascade,
    primary key (imb_i_id, imb_u_id)
);

-- ================================================================
-- item_purchase
-- represents purchase transaction (buy_now bid or win bid)
-- ip_id            purchase's id
-- ip_ib_id            bid's id
-- ip_date            purchase's date
-- ================================================================
drop table if exists item_purchase cascade;
create table item_purchase (
    ip_id               bigint not null,
    ip_ib_id            bigint not null,
    ip_ib_i_id          bigint not null,
    ip_ib_u_id          bigint not null,
    ip_date             timestamp,
    foreign key (ip_ib_id, ip_ib_i_id, ip_ib_u_id) references item_bid (ib_id, ib_i_id, ib_u_id) on delete cascade,
    primary key (ip_id, ip_ib_id, ip_ib_i_id, ip_ib_u_id)
);

-- ================================================================
-- useracct_feedback
-- represents feedbacks between buyers and sellers for a transaction
-- uf_id             feedback's id
-- uf_u_id           the user receiving the feedback
-- uf_i_id           item's id
-- uf_i_u_id         item's seller id
-- uf_from_id        the other user writing the feedback
-- uf_date           feedback's create date
-- uf_comment        feedback by other user
-- ================================================================
drop table if exists useracct_feedback cascade;
create table useracct_feedback (
    uf_u_id             bigint not null references useracct (u_id),
    uf_i_id             bigint not null,
    uf_i_u_id           bigint not null,
    uf_from_id          bigint not null references useracct (u_id),
    uf_rating           int not null,
    uf_date             timestamp,
    uf_sattr0           varchar(80) not null,
    foreign key (uf_i_id, uf_i_u_id) references item (i_id, i_u_id) on delete cascade,
    primary key (uf_u_id, uf_i_id, uf_i_u_id, uf_from_id),
    check (uf_u_id <> uf_from_id)
);

-- ================================================================
-- useracct_item
-- the items that a user has recently purchased
-- ================================================================
drop table if exists useracct_item cascade;
create table useracct_item (
    ui_u_id             bigint not null references useracct (u_id),
    ui_i_id             bigint not null,
    ui_i_u_id           bigint not null,
    ui_ip_id            bigint,
    ui_ip_ib_id         bigint,
    ui_ip_ib_i_id       bigint,
    ui_ip_ib_u_id       bigint,
    ui_created          timestamp,
    foreign key (ui_i_id, ui_i_u_id) references item (i_id, i_u_id) on delete cascade,
    foreign key (ui_ip_id, ui_ip_ib_id, ui_ip_ib_i_id, ui_ip_ib_u_id) references item_purchase (ip_id, ip_ib_id, ip_ib_i_id, ip_ib_u_id) on delete cascade,
    primary key (ui_u_id, ui_i_id, ui_i_u_id)
);
-- create index idx_useracct_item_id on useracct_item (ui_i_id);

-- ================================================================
-- useracct_watch
-- the items that a user is watching
-- ================================================================
drop table if exists useracct_watch cascade;
create table useracct_watch (
    uw_u_id             bigint not null references useracct (u_id),
    uw_i_id             bigint not null,
    uw_i_u_id           bigint not null,
    uw_created          timestamp,
    foreign key (uw_i_id, uw_i_u_id) references item (i_id, i_u_id) on delete cascade,
    primary key (uw_u_id, uw_i_id, uw_i_u_id)
);
