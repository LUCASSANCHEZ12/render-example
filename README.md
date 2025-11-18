# Render + Spring Boot + GitHub Actions + JaCoCo (70% coverage gate)

Este proyecto es un ejemplo mínimo para:

- Aplicación **Spring Boot** con un `HelloController`.
- **JaCoCo** configurado para exigir **>= 70% de cobertura** (LINE) en el paquete `com.example.renderdemo.controller`.
- **GitHub Actions** que:
  - Ejecuta `mvn clean verify` (tests + reporte + check de JaCoCo).
  - **Solo despliega a Render si los tests y el check de cobertura pasan.**
- **Dockerfile** listo para usar en Render (servicio tipo Docker o Web Service usando Dockerfile).

---

## 1. Requisitos

- Java 17
- Maven 3.x
- Cuenta en GitHub
- Cuenta en Render

---

## 2. Estructura del proyecto

- `src/main/java/com/example/renderdemo/DemoApplication.java`  
- `src/main/java/com/example/renderdemo/controller/HelloController.java`  
- `src/test/java/com/example/renderdemo/controller/HelloControllerTest.java`  
- `Dockerfile`  
- `.github/workflows/ci-render.yml`  
- `pom.xml`

---

## 3. JaCoCo: regla de cobertura > 70% en el paquete controller

En el `pom.xml` se ha configurado el plugin de JaCoCo:

- Se ejecuta en la fase `verify`.
- Tiene una regla:

  - `element = PACKAGE`
  - `includes = com.example.renderdemo.controller*`
  - `counter = LINE`
  - `minimum = 0.70`

Si la cobertura de líneas (LINE) promedio en el paquete `controller` es menor al 70%,  
el goal `jacoco:check` falla y por lo tanto `mvn verify` falla → el job de GitHub Actions no pasa → **no se dispara el deploy**.

---

## 4. Probando localmente

```bash
mvn clean verify
```

Deberías ver:

- Tests pasando.
- Reporte de JaCoCo generado en `target/site/jacoco/index.html`.
- Build exitoso (coverage > 70%).

Luego puedes crear el JAR:

```bash
mvn clean package
```

Esto generará:

- `target/render-spring-boot-demo-0.0.1-SNAPSHOT.jar`

Puedes arrancar la app localmente:

```bash
mvn spring-boot:run
# o
java -jar target/render-spring-boot-demo-0.0.1-SNAPSHOT.jar
```

Endpoint:

```bash
curl http://localhost:8080/api/hello
# Hello from Render + GitHub Actions + JaCoCo!
```

---

## 5. Dockerfile

El `Dockerfile` asume que ya se generó el JAR en `target/`:

```bash
mvn clean package -DskipTests
docker build -t render-spring-boot-demo .
docker run -p 8080:8080 render-spring-boot-demo
```

---

## 6. Configuración en Render

1. Haz push de este repo a GitHub.
2. En tu dashboard de Render:
   - Crea un **nuevo servicio Web**.
   - Selecciona el repositorio de GitHub.
   - Elige el tipo de servicio basado en **Dockerfile**.
   - Desactiva auto-deploy si vas a usar deploy hooks + GitHub Actions.
3. En la pestaña **Settings** de tu servicio en Render:
   - Busca la sección **Deploy Hook** y copia la URL.
4. En tu repositorio de GitHub:
   - Ve a `Settings -> Secrets and variables -> Actions`.
   - Crea un secret: `RENDER_DEPLOY_HOOK_URL` con el valor del deploy hook que copiaste.

---

## 7. Flujo de GitHub Actions

Workflow: `.github/workflows/ci-render.yml`

- Se ejecuta en:
  - `push` a `main`
  - `pull_request` a `main`
- Jobs:
  1. Checkout del código.
  2. Configura JDK 17.
  3. Ejecuta `mvn clean verify`:
     - Corre tests.
     - Genera reporte de JaCoCo.
     - Aplica la regla de cobertura (>= 70% para el paquete controller).
  4. Si todo pasa **y** la rama es `main`:
     - Ejecuta `curl -X POST "$RENDER_DEPLOY_HOOK_URL"` para disparar el deploy en Render.

---

## 8. Resumen

- Si escribes tests que mantengan la cobertura del paquete `controller` por encima del 70%, el pipeline de CI pasará y el deploy a Render se disparará automáticamente.
- Si la cobertura baja de 70%, el pipeline fallará y Render **no** desplegará una nueva versión, protegiendo tu entorno de producción.
