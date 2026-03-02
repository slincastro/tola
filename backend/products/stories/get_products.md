Actúa como un ingeniero backend senior experto en FastAPI, AWS Lambda y MongoDB.

Contexto:
	•	Ya existe la colección products en MongoDB (EC2).
	•	Los documentos siguen el schema de producto inmobiliario.
	•	La conexión se obtiene desde MONGODB_URI.
	•	Base de datos: products_db.

Objetivo:

Implementar el endpoint GET /products con buenas prácticas enterprise.

Requisitos funcionales:
	1.	Retornar lista paginada de productos.
	2.	Formato de respuesta:

{
“items”: Product[],
“page”: {
“limit”: number,
“nextCursor”: string | null
}
}
	3.	Soportar query params:

	•	limit (default 20, max 100)
	•	sector (filtro por sector.name)
	•	min_price
	•	max_price
	•	negotiable (boolean)
	•	near_lng
	•	near_lat
	•	radius_meters

	4.	Si vienen near_lng y near_lat:
	•	usar query geoespacial con location.centroid
	•	ordenar por cercanía

Requisitos técnicos:
	•	Usar pymongo
	•	Implementar cursor-based pagination (NO skip/limit)
	•	Excluir campos internos de Mongo
	•	Manejo correcto de errores
	•	Código listo para producción
	•	Optimizar query con índices

Extras importantes:
	•	Incluir creación de índices recomendados
	•	Incluir ejemplo de llamada
	•	Incluir ejemplo de respuesta
	•	Pensar en futura expansión (fotos, status, etc.)

Entregar código limpio y modular.