# 🚀 Simulador de Entrevistas Técnicas

Una plataforma web interactiva diseñada para ayudar a los desarrolladores a prepararse para entrevistas técnicas de programación. Los usuarios pueden autenticarse fácilmente de forma segura, gestionar bancos de preguntas y resolver retos algorítmicos con una interfaz moderna y oscura.

🌐 **Demo en vivo (Despliegue):** [https://simulador-entrevistas.onrender.com](https://simulador-entrevistas.onrender.com)

🌐 **Demo en vivo (Despliegue):** [https://simulador-entrevistas.onrender.com](https://simulador-entrevistas.onrender.com)

## ✨ Características Principales

- **Autenticación con Google**: Sistema de login moderno y seguro mediante *Google Identity Services* permitiendo el acceso rápido al ecosistema.
- **Interfaz Moderna y Oscura (Dark Theme Glassmorphism)**: Diseño profesional e inmersivo para una mejor experiencia visual.
- **Gestión de Retos y Bancos**: Sistema integrado para crear, editar, organizar y probar código en tiempo real.
- **Ejecución de Código en Múltiples Lenguajes**: Soporte para JavaScript, Python, Java, C++ y C# gracias a la integración con la API de Judge0 CE.
- **Optimizado para Entornos Gratuitos y Despliegue en la Nube**: Configurado para Render.com y conexiones con bases de datos como Filess.io.

## 🛠️ Stack Tecnológico

- **Backend**: Node.js, Express.js.
- **Frontend / Vistas**: EJS (Embedded JavaScript templating), HTML5, CSS3 Puro.
- **Autenticación**: google-auth-library (Google OAuth 2).
- **Base de Datos**: MySQL (manejado vía mysql2).
- **Ejecución de Código Remoto**: Judge0 API.

## 📁 Estructura del Proyecto

`	ext
├── public/                 # Archivos estáticos (CSS, hojas de estilos, fuentes)
├── src/
│   ├── config/             # Configuración del entorno (conexión MySQL)
│   ├── controllers/        # Controladores y Lógica (Auth, Bancos, Retos)
│   ├── models/             # Modelos de bases de datos
│   ├── routes/             # Definición de endpoints
│   └── views/              # Vistas EJS 
├── .env                    # Variables de entorno
├── app.js                  # Punto de entrada de la aplicación
└── package.json            # Dependencias
`

## ⚙️ Requisitos Previos

- [Node.js](https://nodejs.org/) (v14 o superior)
- Base de datos MySQL

## 🚀 Instalación y Uso Local

1. **Clonar e instalar dependencias**:
   `ash
   git clone <url-del-repositorio>
   cd simulador-entrevistas
   npm install
   `

2. **Configurar el Entorno (.env)**:
   `env
   DB_HOST=tu_host_mysql
   DB_USER=tu_usuario
   DB_PASSWORD=tu_password
   DB_NAME=nombre_de_bd
   DB_PORT=3306
   `

3. **Ejecutar servidor**:
   `ash
   npm start
   `

4. **Acceder en el navegador**:
   Abre [http://localhost:3000](http://localhost:3000) (o el puerto configurado).
