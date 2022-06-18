ALTER session set NLS_DATE_FORMAT='DD/MM/YYYY';
SET LINESIZE 150
SET PAGESIZE 50
SET SERVEROUTPUT ON
--DROPS TABLES
DROP TABLE RESERVAS;
DROP TABLE MENUS;
DROP TABLE CAMAREROS;

--CREACION DE TABLAS
CREATE TABLE MENUS (
    ENTRANTE VARCHAR2(50) DEFAULT 'Crudites con salsa roquefort',
    PRINCIPAL VARCHAR2(50) NOT NULL,
    POSTRE VARCHAR2(50) NOT NULL,
    PRECIO NUMBER(2) NOT NULL,
    COD_MENU NUMBER(1) PRIMARY KEY
);
CREATE TABLE RESERVAS (
    NOMBRE_RESERVAS VARCHAR2(20) NOT NULL,
    APELLIDO1_RESERVAS VARCHAR2(20),
    APELLIDO2_RESERVAS VARCHAR2(20),
    TELEFONO_RESERVAS NUMBER(9) NOT NULL UNIQUE,
    NUM_PERSONAS NUMBER(2) NOT NULL, 
	DIA DATE,
    HORA VARCHAR2(6),
    COD_MENU NUMBER(1) NOT NULL,
    COD_CAMARERO NUMBER(1) NOT NULL, 
    CONSTRAINT PK_RESERVA PRIMARY KEY (DIA, HORA)
);
CREATE TABLE CAMAREROS (
    NOMBRE_CAMARERO VARCHAR2(20) NOT NULL,
    APELLIDO1_CAMARERO VARCHAR2(20) NOT NULL,
    APELLIDO2_CAMARERO VARCHAR2(20) NOT NULL,
    TELEFONO_CAMARERO NUMBER(9) NOT NULL UNIQUE,
    DNI VARCHAR2(9) NOT NULL,
    COD_CAMARERO NUMBER(1) PRIMARY KEY
);

--FOREIGN KEYS
ALTER TABLE RESERVAS ADD CONSTRAINT FK_RES_MENU FOREIGN KEY (COD_MENU) REFERENCES MENUS(COD_MENU);
ALTER TABLE RESERVAS ADD CONSTRAINT FK_RES_CAMA FOREIGN KEY (COD_CAMARERO) REFERENCES CAMAREROS(COD_CAMARERO);

--DATOS MENUS
INSERT INTO menus (entrante, principal, postre, precio, cod_menu) VALUES ('Sopa de cebolla', 'Berenjena y Pollo a la parmesana', 'Tiramisu', 14, 1);
INSERT INTO menus (entrante, principal, postre, precio, cod_menu) VALUES ('Crudites con salsa roquefort', 'Solomillo de cerdo con patatas asadas', 'Natillas', 13, 2);
INSERT INTO menus (entrante, principal, postre, precio, cod_menu) VALUES ('Revuelto de setas', 'Solomillo Wellington', 'Crema catalana', 15, 3);
INSERT INTO menus (entrante, principal, postre, precio, cod_menu) VALUES ('Habas con jamon', 'Pechuga de pollo al horno', 'Yogurt griego con frutos del bosque', 12, 4);

--DATOS CAMAREROS
INSERT INTO camareros (nombre_camarero, apellido1_camarero, apellido2_camarero, telefono_camarero, dni, cod_camarero) VALUES ('Manuel', 'Fernandez', 'Pola', 954663311, '12345678A', 1);
INSERT INTO camareros (nombre_camarero, apellido1_camarero, apellido2_camarero, telefono_camarero, dni, cod_camarero) VALUES ('Vanesa', 'Vera', 'Viviana', 954123456, '98765432B', 2);
INSERT INTO camareros (nombre_camarero, apellido1_camarero, apellido2_camarero, telefono_camarero, dni, cod_camarero) VALUES ('Dolores', 'Fuertes', 'Barriga', 954695843, '23456789C', 3);
INSERT INTO camareros (nombre_camarero, apellido1_camarero, apellido2_camarero, telefono_camarero, dni, cod_camarero) VALUES ('Kenneth', 'Martin', 'Follett', 954765780, '87654321D', 4);
INSERT INTO camareros (nombre_camarero, apellido1_camarero, apellido2_camarero, telefono_camarero, dni, cod_camarero) VALUES ('James', 'Jonah', 'Jameson', 954123324, '48765419E', 5);

COMMIT;

--FUNCIONES

CREATE OR REPLACE FUNCTION HayReserva(d_dia RESERVAS.DIA%TYPE, d_hora RESERVAS.HORA%TYPE) RETURN BOOLEAN --Esta funci�n devolver� TRUE o FALSE en caso de que haya una reserva para ese d�a y esa hora que hemos introducido.
AS
	v_reserva RESERVAS%ROWTYPE;
BEGIN
	SELECT * INTO v_reserva FROM RESERVAS WHERE DIA=d_dia AND HORA=d_hora;
	RETURN TRUE; --Retornar� TRUE en caso de que encuentre una fila que contenga la fecha y hora indicada.
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		DBMS_OUTPUT.PUT_LINE('No hay ninguna reserva el d�a '||d_dia||' a las '||d_hora);
		RETURN FALSE;--Gracias a la excepci�n, si no encuentra datos, devolver� FALSE.
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error encontrado, no se pudo efectuar la funci�n');--En caso de que haya un error m�s grave, saldr� esto y no devolver� nada
        RETURN NULL;
END;
/

CREATE OR REPLACE FUNCTION PrecioReserva(d_dia RESERVAS.DIA%TYPE, d_hora RESERVAS.HORA%TYPE) RETURN NUMBER--Esta funci�n nos mostrar� cuanto dinero costar� la reserva de tal d�a y hora, teniendo en cuenta el n�mero de comensales y el men� que seleccionaron
AS
	v_reserva RESERVAS%ROWTYPE;
	v_menu MENUS%ROWTYPE;
	v_precio NUMBER(10);
BEGIN 
	SELECT * INTO v_reserva FROM RESERVAS WHERE DIA=d_dia AND HORA=d_hora;--Hacemos un cursor impl�cito para hallar la reserva de la que queremos hallar el precio y sacamos el numero de comensales
	SELECT * INTO v_menu FROM MENUS WHERE COD_MENU=v_reserva.COD_MENU;--Con ayuda del anterior cursor, hallamos que men� seleccionaron, y con �l sacamos el precio
	v_precio := v_reserva.NUM_PERSONAS*v_menu.PRECIO;
	RETURN v_precio;
EXCEPTION
	WHEN NO_DATA_FOUND THEN --En caso de no encontrar datos
		DBMS_OUTPUT.PUT_LINE('No se han encontrado los datos necesarios para esta operaci�n. Compruebe que exista la reserva o el men� al que se hagan referencia');
		RETURN NULL;
	WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error encontrado, no se pudo efectuar la funci�n');--En caso de que haya un error m�s grave, saldr� esto y no devolver� nada
        RETURN NULL;
END;
/

--PROCEDIMIENTOS

CREATE OR REPLACE PROCEDURE InsertarReserva(d_nombre reservas.nombre_reservas%TYPE, d_apellido1 reservas.apellido1_reservas%TYPE, d_apellido2 reservas.apellido2_reservas%TYPE, d_telefono reservas.telefono_reservas%TYPE, d_num_personas reservas.num_personas%TYPE, d_dia RESERVAS.DIA%TYPE, d_hora RESERVAS.HORA%TYPE, d_cod_menu reservas.cod_menu%TYPE, d_cod_camarero reservas.cod_camarero%TYPE) 
--Este proceso lo que har� ser� insertar en la tabla de RESERVAS los datos de la reserva cumpliendo todos nuestras condiciones para que se pueda reservar bien
AS
	v_camareros NUMBER(3);
	v_camarerodatos CAMAREROS%ROWTYPE;
	v_dia NUMBER(3);
	v_precio NUMBER(10);
BEGIN
	SELECT COUNT(*) INTO v_dia FROM RESERVAS WHERE DIA=d_dia AND HORA=d_hora;
	SELECT COUNT(*) INTO v_camareros FROM RESERVAS WHERE DIA=d_dia AND HORA=d_hora AND COD_CAMARERO=d_cod_camarero;
	SELECT * INTO v_camarerodatos FROM CAMAREROS WHERE COD_CAMARERO=d_cod_camarero;
	IF HayReserva(d_dia, d_hora)=TRUE THEN
		DBMS_OUTPUT.PUT_LINE('El d�a '||d_dia||' a las '||d_hora||' ya hay una reserva.');
	ELSIF v_dia > 3 THEN --Solo permite 3 eventos al d�a.
		DBMS_OUTPUT.PUT_LINE('En este d�a ya hay m�s de 3 reservas. Por favor, llame al cliente '||d_nombre||' '||d_apellido1||' '||d_apellido2||' al tel�fono '||d_telefono||' de que elija otra fecha.');
	ELSIF v_camareros>1 THEN --Solo permite a 1 camarero atender un evento al d�a.
		DBMS_OUTPUT.PUT_LINE(v_camarerodatos.NOMBRE_CAMARERO||' '||v_camarerodatos.APELLIDO1_CAMARERO||' ya se esta encargando de un evento ese mismo d�a, por favor elija a otro camarero.');
	ELSE
		INSERT INTO RESERVAS VALUES (d_nombre, d_apellido1, d_apellido2, d_telefono, d_num_personas, d_dia, d_hora, d_cod_menu, d_cod_camarero);
        v_precio := PrecioReserva(d_dia, d_hora);
		DBMS_OUTPUT.PUT_LINE('Reserva registrada correctamente el '||d_dia||' a las '||d_hora||'. El cliente deber� abonar '||v_precio||' euros');
	END IF;
EXCEPTION
	WHEN NO_DATA_FOUND THEN --En caso de no encontrar datos
		DBMS_OUTPUT.PUT_LINE('No se han encontrado los datos necesarios para esta operaci�n.');
	WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error encontrado, no se pudo efectuar la funci�n');--En caso de que haya un error m�s grave, saldr� esto y no devolver� nada
END;
/

CREATE OR REPLACE PROCEDURE CambiarMenu(d_principal MENUS.PRINCIPAL%TYPE, d_precio MENUS.PRECIO%TYPE, d_cod MENUS.COD_MENU%TYPE)
--Este procedimiento nos permitir� cambiar el plato principal de un men� en concreto, y adaptar el nuevo precio que le queramos poner
AS
BEGIN
UPDATE MENUS SET PRINCIPAL = d_principal, PRECIO = d_precio WHERE COD_MENU=d_cod;
EXCEPTION
	WHEN NO_DATA_FOUND THEN --En caso de no encontrar datos
		DBMS_OUTPUT.PUT_LINE('No se han encontrado los datos necesarios del men� para esta operaci�n.');
	WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error encontrado, no se pudo efectuar la funci�n');--En caso de que haya un error m�s grave, saldr� esto y no devolver� nada
END;
/



--BLOQUE AN�NIMO
DECLARE
    CURSOR c_reservas IS SELECT * FROM RESERVAS;
    v_reservas c_reservas%ROWTYPE;
    CURSOR c_menus IS SELECT * FROM MENUS;
    v_menus c_menus%ROWTYPE;
BEGIN
    --Empezamos insertando los datos en la tabla RESERVAS
	InsertarReserva('Alberto', 'Sanabria', 'Garc�a', 954442233, 8,'17:00', SYSDATE, 2,3);
	InsertarReserva('Manuel', 'Navas', 'Garc�a', 123456789, 20,'22:00', SYSDATE, 1,5);
    InsertarReserva('Isabel', 'Sanabria', 'Jimenez', 987654321, 10,'14:00', SYSDATE, 3,5);--Este no se deber� insertar, porque se debe cumplir la norma de "No m�s de un evento por camarero al d�a".
	InsertarReserva('Isabel', 'Sanabria', 'Jimenez', 987654321, 10,'14:00', SYSDATE, 3,1);
	InsertarReserva('Daniel', 'Segura', 'Velasco', 954422334, 6,'20:00', SYSDATE, 4,2); --Este �ltimo, no deber�a ser insertado debido a que ya se ha cumplido el cupo de 3 reservas al d�a.
    OPEN c_reservas;--Ahora comprobaremos que reservas se han insertado... las cuales solo deber�n haber 3.
	LOOP
        FETCH c_reservas INTO v_reservas;
        EXIT WHEN c_reservas%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Nombre: '||v_reservas.nombre_reservas||' '||v_reservas.apellido1_reservas||' '||v_reservas.apellido2_reservas||' Telefono: '||v_reservas.telefono_reservas||' N� personas: '||v_reservas.num_personas||' Fecha: '||v_reservas.dia ||' '||v_reservas.hora||' Cod.Menu: '||v_reservas.cod_menu||' Cod.Camarero '||v_reservas.cod_camarero);
    END LOOP;
    CLOSE c_reservas;
	DBMS_OUTPUT.PUT_LINE('-------------------');
	OPEN c_menus;--Primero imprimiremos uno de los menus ya ingresados
    FETCH c_menus INTO v_menus;
    DBMS_OUTPUT.PUT_LINE('Codigo: '||v_menus.cod_menu||' Entrante: '||v_menus.entrante||' Principal: '||v_menus.principal||' Postre: '||v_menus.postre||' Precio: '||v_menus.precio);
    CLOSE c_menus;
	CambiarMenu('Codillo en salsa de pasas', 18, 3);--Realizamos la modificaci�n con el procedimiento
    OPEN c_menus;
    FETCH c_menus INTO v_menus;--Aqu� ya saldr� el mismo men� modificado.
    DBMS_OUTPUT.PUT_LINE('Codigo: '||v_menus.cod_menu||' Entrante: '||v_menus.entrante||' Principal: '||v_menus.principal||' Postre: '||v_menus.postre||' Precio: '||v_menus.precio);
    CLOSE c_menus;
END;
/