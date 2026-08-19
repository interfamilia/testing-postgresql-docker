\copy prefecture FROM '/csv/prefecture.csv' WITH (FORMAT csv, ENCODING 'UTF8')
\copy municipality (municipality_code, municipality_name, municipality_name_kana, municipality_name_rome, prefecture_code) FROM '/csv/municipality.csv' WITH (FORMAT csv, ENCODING 'UTF8', FORCE_NULL (municipality_name_rome))
\copy postal_address (postal_code, municipality_code, street_name, street_name_kana, street_name_rome) FROM '/csv/postal_address.csv' WITH (FORMAT csv, ENCODING 'UTF8', FORCE_NULL (street_name_rome))
