# Base-de-Datos-PL-SQL
Proyecto de clase
Base de datos creada para un proyecto de clases de BBDD. Este repositorio cuenta con un único archivo SQL creado en SQL Developer, el cual contiene una base de datos 
de tres tablas entrelazadas entre ellas, además de varios bloques PL/SQL entre los que encontramos dos procedimientos (HayReserva,PrecioReserva), 
dos funciones () y un bloque anónimo.
El objetivo del bloque anónimo es el de insertar varias columnas en la tabla principal, RESERVAS, y modificar los datos de la tabla MENUS, concretamente el menú 
cuyo COD_MENU=3.

ADVERTENCIA:
A la hora de ejecutar el bloque anónimo, puede darse un error debido a que el sistema no parece identificar bien el mes de la fecha aportada a la hora de rellenar la tabla con el procedimiento 'InsertarReservas', del cual ya se le fue notificado en clase el 20/06/2022 a las 11:10 de la mañana y hemos intentado arreglar sin éxito. El error en cuestión es:

||ORA-01843: not a valid month||
||ORA-06512: at line 8||
||01843. 00000 -  "not a valid month"||

Pero si realiza el procedimiento de forma separada seleccionándolo en el menú de Procedimientos, verá que el procedimiento cumple su función de insertar datos en la tabla RESERVAS.

Trabajo creado por Daniel Segura Velasco.
