import os

# ============================
# CONFIGURACIÓN DE EXCLUSIONES
# ============================

EXCLUDED_DIRS = {
    ".git",
    "__pycache__",
    "node_modules",
    ".idea",
    ".vscode",
    "dist",
    "build",
    "patches",
    "scripts",
    ".expo",
    ".vscodeg",
    "vendor"
}

EXCLUDED_FILES = {
    "resultado_unificado.txt",
    ".DS_Store",
    "package-lock.json",
    ".gitignore"
}

# ============================
# PROGRAMA PRINCIPAL
# ============================

def main():
    base_dir = os.path.dirname(os.path.abspath(__file__))
    os.chdir(base_dir)

    print(f"Carpeta base:\n{base_dir}\n")

    output_filename = "xxx_resultado_unificado.txt"
    script_path = os.path.abspath(__file__)
    output_path = os.path.join(base_dir, output_filename)

    print("Iniciando búsqueda recursiva...\n")

    with open(output_path, "w", encoding="utf-8") as out:
        for root, dirs, files in os.walk(base_dir):

            # ============================
            # FILTRAR DIRECTORIOS (IN-PLACE)
            # ============================
            dirs[:] = [
                d for d in dirs
                if d not in EXCLUDED_DIRS
            ]

            # ============================
            # PROCESAR ARCHIVOS
            # ============================
            for filename in files:

                if filename in EXCLUDED_FILES:
                    print(f"[SKIP] {filename} (archivo excluido)")
                    continue

                filepath = os.path.join(root, filename)

                # Saltar el propio script
                if os.path.abspath(filepath) == script_path:
                    print(f"[SKIP] {filename} (script)")
                    continue

                try:
                    with open(filepath, "r", encoding="utf-8", errors="ignore") as f:
                        rel_path = os.path.relpath(filepath, base_dir)
                        print(f"[OK] Copiando: {rel_path}")

                        out.write(f"===== ARCHIVO: {rel_path} =====\n")
                        out.write(f.read())
                        out.write("\n\n")

                except Exception as e:
                    print(f"[ERROR] No se pudo leer {filepath}: {e}")

    print("\n✔ Proceso finalizado.")
    print(f"✔ Archivo generado: {output_path}\n")
    input("Presiona ENTER para salir...")

if __name__ == "__main__":
    main()
