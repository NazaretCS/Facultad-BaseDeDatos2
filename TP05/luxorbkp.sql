PGDMP         7                {            bdLuxor    10.16    10.16 .    B           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                       false            C           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                       false            D           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                       false            E           1262    49152    bdLuxor    DATABASE     �   CREATE DATABASE "bdLuxor" WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'Spanish_Spain.1252' LC_CTYPE = 'Spanish_Spain.1252';
    DROP DATABASE "bdLuxor";
             postgres    false                        2615    2200    public    SCHEMA        CREATE SCHEMA public;
    DROP SCHEMA public;
             postgres    false            F           0    0    SCHEMA public    COMMENT     6   COMMENT ON SCHEMA public IS 'standard public schema';
                  postgres    false    3                        3079    12924    plpgsql 	   EXTENSION     ?   CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;
    DROP EXTENSION plpgsql;
                  false            G           0    0    EXTENSION plpgsql    COMMENT     @   COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';
                       false    1            Y           1247    49168    cargo    TYPE     h   CREATE TYPE public.cargo AS ENUM (
    'Administrativo',
    'Cajero',
    'Vendedor',
    'Gerente'
);
    DROP TYPE public.cargo;
       public       postgres    false    3            g           1247    49215 	   categoria    TYPE     f   CREATE TYPE public.categoria AS ENUM (
    'Bebidas',
    'Carnes',
    'Lácteos',
    'Cereales'
);
    DROP TYPE public.categoria;
       public       postgres    false    3                       1247    49158 	   domicilio    TYPE     �   CREATE TYPE public.domicilio AS (
	calle character varying(120),
	numero character varying(7),
	ciudad character varying(120),
	provincia character varying(120)
);
    DROP TYPE public.domicilio;
       public       postgres    false    3            \           1247    49178    sector    TYPE     d   CREATE TYPE public.sector AS ENUM (
    'Ventas ',
    'Compras',
    'Gerencia',
    'Deposito'
);
    DROP TYPE public.sector;
       public       postgres    false    3            �            1259    49159    persona    TABLE     �   CREATE TABLE public.persona (
    id_persona integer NOT NULL,
    nombre character varying(300) NOT NULL,
    dni integer NOT NULL,
    domicilio public.domicilio NOT NULL,
    email character varying(80)[],
    telefono character varying(18)[]
);
    DROP TABLE public.persona;
       public         postgres    false    515    3            �            1259    49203    cliente    TABLE     ^   CREATE TABLE public.cliente (
    cta_cte character varying(150)
)
INHERITS (public.persona);
    DROP TABLE public.cliente;
       public         postgres    false    3    515    197            �            1259    49197    empleado    TABLE     �   CREATE TABLE public.empleado (
    cargo public.cargo NOT NULL,
    sector public.sector NOT NULL,
    legajo character varying(80),
    sueldo numeric(9,2)
)
INHERITS (public.persona);
    DROP TABLE public.empleado;
       public         postgres    false    197    3    604    601    515            �            1259    49263    pedido    TABLE     �   CREATE TABLE public.pedido (
    id_pedido integer NOT NULL,
    fecha date NOT NULL,
    total numeric(9,2) NOT NULL,
    id_empleado integer NOT NULL,
    id_cliente integer NOT NULL
);
    DROP TABLE public.pedido;
       public         postgres    false    3            �            1259    49301    pedidos2020    TABLE     �   CREATE TABLE public.pedidos2020 (
    CONSTRAINT pedidos2020_fecha_check CHECK (((fecha >= '2020-01-01'::date) AND (fecha < '2020-12-31'::date)))
)
INHERITS (public.pedido);
    DROP TABLE public.pedidos2020;
       public         postgres    false    3    200            �            1259    49307    pedidos2021    TABLE     �   CREATE TABLE public.pedidos2021 (
    CONSTRAINT factura2021_fecha_check CHECK (((fecha >= '2021-01-01'::date) AND (fecha < '2021-12-31'::date)))
)
INHERITS (public.pedido);
    DROP TABLE public.pedidos2021;
       public         postgres    false    200    3            �            1259    49317    pedidos2022    TABLE     �   CREATE TABLE public.pedidos2022 (
    CONSTRAINT pedidos2022_fecha_check CHECK (((fecha >= '2022-01-01'::date) AND (fecha < '2022-12-31'::date)))
)
INHERITS (public.pedido);
    DROP TABLE public.pedidos2022;
       public         postgres    false    200    3            �            1259    49323    pedidos2023    TABLE     �   CREATE TABLE public.pedidos2023 (
    CONSTRAINT pedidos2023_fecha_check CHECK (((fecha >= '2023-01-01'::date) AND (fecha < '2023-12-31'::date)))
)
INHERITS (public.pedido);
    DROP TABLE public.pedidos2023;
       public         postgres    false    3    200            �            1259    49278    producto    TABLE       CREATE TABLE public.producto (
    id_producto integer NOT NULL,
    nombre character varying(150) NOT NULL,
    descripcion character varying(400),
    precio numeric(9,2) NOT NULL,
    categoria character varying(150),
    proveedor character varying(150)[]
);
    DROP TABLE public.producto;
       public         postgres    false    3            �            1259    49286    tienen    TABLE     �   CREATE TABLE public.tienen (
    id_producto integer NOT NULL,
    id_pedido integer NOT NULL,
    cantidad smallint NOT NULL,
    precio numeric(9,2) NOT NULL
);
    DROP TABLE public.tienen;
       public         postgres    false    3            8          0    49203    cliente 
   TABLE DATA               _   COPY public.cliente (id_persona, nombre, dni, domicilio, email, telefono, cta_cte) FROM stdin;
    public       postgres    false    199   �2       7          0    49197    empleado 
   TABLE DATA               v   COPY public.empleado (id_persona, nombre, dni, domicilio, email, telefono, cargo, sector, legajo, sueldo) FROM stdin;
    public       postgres    false    198   4       9          0    49263    pedido 
   TABLE DATA               R   COPY public.pedido (id_pedido, fecha, total, id_empleado, id_cliente) FROM stdin;
    public       postgres    false    200   '5       <          0    49301    pedidos2020 
   TABLE DATA               W   COPY public.pedidos2020 (id_pedido, fecha, total, id_empleado, id_cliente) FROM stdin;
    public       postgres    false    203   D5       =          0    49307    pedidos2021 
   TABLE DATA               W   COPY public.pedidos2021 (id_pedido, fecha, total, id_empleado, id_cliente) FROM stdin;
    public       postgres    false    204   a5       >          0    49317    pedidos2022 
   TABLE DATA               W   COPY public.pedidos2022 (id_pedido, fecha, total, id_empleado, id_cliente) FROM stdin;
    public       postgres    false    205   �5       ?          0    49323    pedidos2023 
   TABLE DATA               W   COPY public.pedidos2023 (id_pedido, fecha, total, id_empleado, id_cliente) FROM stdin;
    public       postgres    false    206   �5       6          0    49159    persona 
   TABLE DATA               V   COPY public.persona (id_persona, nombre, dni, domicilio, email, telefono) FROM stdin;
    public       postgres    false    197   
6       :          0    49278    producto 
   TABLE DATA               b   COPY public.producto (id_producto, nombre, descripcion, precio, categoria, proveedor) FROM stdin;
    public       postgres    false    201   '6       ;          0    49286    tienen 
   TABLE DATA               J   COPY public.tienen (id_producto, id_pedido, cantidad, precio) FROM stdin;
    public       postgres    false    202   "7       �
           2606    49262    cliente cliente_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.cliente
    ADD CONSTRAINT cliente_pkey PRIMARY KEY (id_persona);
 >   ALTER TABLE ONLY public.cliente DROP CONSTRAINT cliente_pkey;
       public         postgres    false    199            �
           2606    49260    empleado empleado_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.empleado
    ADD CONSTRAINT empleado_pkey PRIMARY KEY (id_persona);
 @   ALTER TABLE ONLY public.empleado DROP CONSTRAINT empleado_pkey;
       public         postgres    false    198            �
           2606    49166    persona id_persona 
   CONSTRAINT     X   ALTER TABLE ONLY public.persona
    ADD CONSTRAINT id_persona PRIMARY KEY (id_persona);
 <   ALTER TABLE ONLY public.persona DROP CONSTRAINT id_persona;
       public         postgres    false    197            �
           2606    49267    pedido pedido_pkey 
   CONSTRAINT     W   ALTER TABLE ONLY public.pedido
    ADD CONSTRAINT pedido_pkey PRIMARY KEY (id_pedido);
 <   ALTER TABLE ONLY public.pedido DROP CONSTRAINT pedido_pkey;
       public         postgres    false    200            �
           2606    49306    pedidos2020 pk1 
   CONSTRAINT     T   ALTER TABLE ONLY public.pedidos2020
    ADD CONSTRAINT pk1 PRIMARY KEY (id_pedido);
 9   ALTER TABLE ONLY public.pedidos2020 DROP CONSTRAINT pk1;
       public         postgres    false    203            �
           2606    49312    pedidos2021 pk2 
   CONSTRAINT     T   ALTER TABLE ONLY public.pedidos2021
    ADD CONSTRAINT pk2 PRIMARY KEY (id_pedido);
 9   ALTER TABLE ONLY public.pedidos2021 DROP CONSTRAINT pk2;
       public         postgres    false    204            �
           2606    49322    pedidos2022 pk3 
   CONSTRAINT     T   ALTER TABLE ONLY public.pedidos2022
    ADD CONSTRAINT pk3 PRIMARY KEY (id_pedido);
 9   ALTER TABLE ONLY public.pedidos2022 DROP CONSTRAINT pk3;
       public         postgres    false    205            �
           2606    49328    pedidos2023 pk4 
   CONSTRAINT     T   ALTER TABLE ONLY public.pedidos2023
    ADD CONSTRAINT pk4 PRIMARY KEY (id_pedido);
 9   ALTER TABLE ONLY public.pedidos2023 DROP CONSTRAINT pk4;
       public         postgres    false    206            �
           2606    49285    producto producto_pkey 
   CONSTRAINT     ]   ALTER TABLE ONLY public.producto
    ADD CONSTRAINT producto_pkey PRIMARY KEY (id_producto);
 @   ALTER TABLE ONLY public.producto DROP CONSTRAINT producto_pkey;
       public         postgres    false    201            �
           2606    49290    tienen tienen_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.tienen
    ADD CONSTRAINT tienen_pkey PRIMARY KEY (id_producto, id_pedido);
 <   ALTER TABLE ONLY public.tienen DROP CONSTRAINT tienen_pkey;
       public         postgres    false    202    202            �
           2606    49273    pedido id_cliente    FK CONSTRAINT     �   ALTER TABLE ONLY public.pedido
    ADD CONSTRAINT id_cliente FOREIGN KEY (id_cliente) REFERENCES public.cliente(id_persona) ON UPDATE CASCADE ON DELETE CASCADE;
 ;   ALTER TABLE ONLY public.pedido DROP CONSTRAINT id_cliente;
       public       postgres    false    199    2730    200            �
           2606    49268    pedido id_empleado    FK CONSTRAINT     �   ALTER TABLE ONLY public.pedido
    ADD CONSTRAINT id_empleado FOREIGN KEY (id_empleado) REFERENCES public.empleado(id_persona) ON UPDATE CASCADE ON DELETE CASCADE;
 <   ALTER TABLE ONLY public.pedido DROP CONSTRAINT id_empleado;
       public       postgres    false    198    200    2728            �
           2606    49296    tienen id_pedido    FK CONSTRAINT     �   ALTER TABLE ONLY public.tienen
    ADD CONSTRAINT id_pedido FOREIGN KEY (id_pedido) REFERENCES public.pedido(id_pedido) ON UPDATE CASCADE ON DELETE CASCADE;
 :   ALTER TABLE ONLY public.tienen DROP CONSTRAINT id_pedido;
       public       postgres    false    202    200    2732            �
           2606    49291    tienen id_producto    FK CONSTRAINT     �   ALTER TABLE ONLY public.tienen
    ADD CONSTRAINT id_producto FOREIGN KEY (id_producto) REFERENCES public.producto(id_producto) ON UPDATE CASCADE ON DELETE CASCADE;
 <   ALTER TABLE ONLY public.tienen DROP CONSTRAINT id_producto;
       public       postgres    false    2734    202    201            8   x  x�u�]K�0���_z�p(M�����.ӎ~ٴ��n�����^8��M+���$!�缇���TUu�tSΤE\�3;CMcuY)j�d`J�ʰA�X;����~ӽ���n�u�w��(��| L2i	r�b��d�NR���,�,��,)�2�SIИ5���c߽��ۮ�?ƅ�1�Γd���U7@g-DS���$�9�P��N5�jU�q�&&�)���|�W�����q�d��:�ea���\i�9.j4�1�]�.fNE�f�XL�"��1��3�n�:1�����{�
�e�i�&%�"7�����e��S�2 ��N�&`V�cah���|0^����y\H�x �#�.˲� S��E      7   �   x�M�Kk�0���W�Y�Bn�wDJ����b�FDJ��0Ӻ��ot
�{g�!�&�uYYR�$���C�y��p�-�t^kR�>P�0��X���]���n���SgG��u����]�m�p�>FJ
*��@Ry�n�
q�1\fh��gw%���wa�{�&7'J*��F�%� �Ȉ.��Ƽ8�J�J���g�������j����'�Đ;nq�g�I%�
O����{�����"��{c��� ��V�      9      x������ � �      <      x������ � �      =   $   x�3�4202�50�52�4646�҆�&\1z\\\ Nv�      >   *   x�3�020�4202�5��54�4535�32�4�4����� h��      ?   +   x�36560�4202�50�54�442�0�31�4�4����� o�      6      x������ � �      :   �   x���=N1���)F[G�c���
�[� �L��pb4�%P���,\�]/ ("ѽb�7�[�&ZBA��p-�9&h��T
:��{Jp��)��/v���&I����8���3%�O\��d̕��ۏw�����l���jf�cw�I4�/����Cqiѓ}�Wl.�����fNO����C�Z�Q�л���zj�D�>'Z�6����C;�pN������F�����>J!�'G���      ;      x������ � �     