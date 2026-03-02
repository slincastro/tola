Actúa como un ingeniero backend senior en Python (FastAPI) con experiencia en AWS Lambda y MongoDB.

Contexto:
	•	La aplicación ya existe.
	•	MongoDB está corriendo en una instancia EC2.
	•	La API es serverless (AWS Lambda).
	•	La colección se llama: products.
	•	La conexión a Mongo debe leerse desde la variable de entorno MONGODB_URI.
	•	La base de datos se llama: products_db.

Objetivo:

Crear el endpoint POST /products que inserte un producto con la siguiente estructura extensible:

{
“mid”: string,
“name”: string,
“description”: string,
“surface”: { “value”: number, “unit”: “m2” },
“services”: string[],
“price”: { “amount”: number, “currency”: “USD”, “negotiable”: boolean },
“sector”: { “name”: string, “city”: string, “province”: string, “country”: string },
“location”: {
“geometry”: { “type”: “Polygon”, “coordinates”: number[][][] },
“centroid”: { “type”: “Point”, “coordinates”: number[] }
},
“media”: { “photos”: [] }
}

Requisitos técnicos:
	1.	Usar FastAPI.
	2.	Usar pymongo (no motor async).
	3.	Crear un modelo Pydantic para validación.
	4.	Generar automáticamente:
	•	id (UUID o ObjectId)
	•	createdAt
	•	updatedAt
	5.	Validar que el Polygon tenga al menos 4 puntos y esté cerrado.
	6.	Manejar errores con HTTPException.
	7.	El código debe ser production-ready.
	8.	Preparar la colección para índice geoespacial 2dsphere en:
	•	location.geometry
	•	location.centroid
Requisitos técnicos:
	1.	Usar FastAPI.
	2.	Usar pymongo (no motor async).
	3.	Crear un modelo Pydantic para validación.
	4.	Generar automáticamente:
	•	id (UUID o ObjectId)
	•	createdAt
	•	updatedAt
	5.	Validar que el Polygon tenga al menos 4 puntos y esté cerrado.
	6.	Manejar errores con HTTPException.
	7.	El código debe ser production-ready.
	8.	Preparar la colección para índice geoespacial 2dsphere en:
	•	location.geometry
	•	location.centroid

Entregar:
	•	archivo completo del endpoint
	•	función de conexión reutilizable a Mongo
	•	ejemplo de request válido