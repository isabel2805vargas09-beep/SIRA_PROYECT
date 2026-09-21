# SIRA Web — Flutter + Supabase

Proyecto Flutter Web del Sistema de Información para el Registro de Aprendices (SIRA), con el diseño rosa/magenta de la referencia original.

## Acceso visual

- Usuario: `Administrador`
- Contraseña: `SENA_TOL3409633`

## Supabase configurado

- URL: `https://kdzfzxqkwkdyugccdggn.supabase.co`
- Publishable key: `sb_publishable_5V42zkxvcGh3pFn0AfoTtw_9XcdVXGt`

## Tablas y columnas usadas

### `departamento`
- `código`
- `nombre`

### `ciudad`
- `departamento`
- `código`
- `nombre`

### `aprendiz`
- `id` (`int4`)
- `nombre1`
- `nombre2`
- `apellido1`
- `apellido2`
- `genero`
- `fecha_nacimiento`
- `departamento_residencia`
- `ciudad_residencia`
- `celular`
- `email`

La corrección importante frente al proyecto anterior es que el registro usa `departamento_residencia` y `ciudad_residencia`, no `departamento` ni `ciudad`.

## Interfaz

- Mantiene el fondo rosado, panel lateral magenta, tipografía DM Sans/Playfair Display y las tres secciones del formulario.
- La barra lateral se puede ocultar y volver a desplegar desde el botón de menú.
- La barra lateral y el formulario tienen desplazamiento para evitar el `BOTTOM OVERFLOW` y no aparece la franja amarilla de Flutter.
- En ventanas pequeñas el contenido se adapta sin cortar la barra lateral.

## Ejecutar

```bash
flutter pub get
flutter run -d chrome
```

Producción:

```bash
flutter build web
```
