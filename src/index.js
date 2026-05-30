exports.handler = async (event) => {
    console.log("Evento recibido de forma asíncrona:", JSON.stringify(event));
    
    const response = {
        statusCode: 200,
        body: JSON.stringify({
            message: '¡Hola desde AWS Lambda + Terraform!',
            fecha: new Date().toISOString()
        }),
    };
    return response;
};