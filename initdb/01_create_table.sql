-- 都道府県
CREATE TABLE prefecture (
    prefecture_code      char(2) NOT NULL,
    prefecture_name      text    NOT NULL,
    prefecture_name_kana text    NOT NULL,
    prefecture_name_rome text    NOT NULL,
    CONSTRAINT pk_prefecture PRIMARY KEY (prefecture_code)
);

COMMENT ON TABLE  prefecture                      IS '都道府県';
COMMENT ON COLUMN prefecture.prefecture_code      IS '都道府県コード';
COMMENT ON COLUMN prefecture.prefecture_name      IS '都道府県名';
COMMENT ON COLUMN prefecture.prefecture_name_kana IS '都道府県名カナ';
COMMENT ON COLUMN prefecture.prefecture_name_rome IS '都道府県名ローマ字';

-- 市区町村
CREATE TABLE municipality (
    municipality_code      char(5) NOT NULL,
    municipality_name      text    NOT NULL,
    municipality_name_kana text    NOT NULL,
    municipality_name_rome text,
    prefecture_code        char(2) NOT NULL,
    CONSTRAINT pk_municipality PRIMARY KEY (municipality_code),
    CONSTRAINT fk_municipality_prefecture FOREIGN KEY (prefecture_code)
        REFERENCES prefecture (prefecture_code)
);

COMMENT ON TABLE  municipality                        IS '市区町村';
COMMENT ON COLUMN municipality.municipality_code      IS '市区町村コード';
COMMENT ON COLUMN municipality.municipality_name      IS '市区町村名';
COMMENT ON COLUMN municipality.municipality_name_kana IS '市区町村名カナ';
COMMENT ON COLUMN municipality.municipality_name_rome IS '市区町村名ローマ字';
COMMENT ON COLUMN municipality.prefecture_code        IS '都道府県コード';

-- 郵便住所
CREATE TABLE postal_address (
    id                bigint GENERATED ALWAYS AS IDENTITY,
    postal_code       char(7) NOT NULL,
    municipality_code char(5) NOT NULL,
    street_name       text    NOT NULL,
    street_name_kana  text    NOT NULL,
    street_name_rome  text,
    CONSTRAINT pk_postal_address PRIMARY KEY (id),
    CONSTRAINT fk_postal_address_municipality FOREIGN KEY (municipality_code)
        REFERENCES municipality (municipality_code)
);

COMMENT ON TABLE  postal_address                   IS '郵便住所';
COMMENT ON COLUMN postal_address.id                IS 'ID';
COMMENT ON COLUMN postal_address.postal_code       IS '郵便番号';
COMMENT ON COLUMN postal_address.municipality_code IS '市区町村コード';
COMMENT ON COLUMN postal_address.street_name       IS '町域名';
COMMENT ON COLUMN postal_address.street_name_kana  IS '町域名カナ';
COMMENT ON COLUMN postal_address.street_name_rome  IS '町域名ローマ字';

-- 検索用のインデックス
CREATE INDEX idx_municipality_prefecture_code ON municipality (prefecture_code);
CREATE INDEX idx_postal_address_postal_code   ON postal_address (postal_code);
