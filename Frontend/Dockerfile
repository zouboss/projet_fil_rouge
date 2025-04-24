# 1. Utilise l'image officielle de Node.js
FROM node:18-alpine AS build

# 2. Crée un dossier de travail dans le conteneur
WORKDIR /app

# 3. Copie les fichiers du projet
COPY package.json ./

# 4. Installe les dépendances
RUN npm install

# 5. Copie le reste des fichiers
COPY . .

# 6. Build l'application
RUN npm run build

# Phase de production
FROM nginx:stable-alpine AS production

# 🔥 On ajoute le fichier de config nginx
COPY nginx/default.conf /etc/nginx/conf.d/default.conf

# Copie des fichiers générés
COPY --from=build /app/dist /usr/share/nginx/html

# Exposition du port
EXPOSE 80

# Démarrage de nginx
CMD ["nginx","-g", "daemon off;"]
