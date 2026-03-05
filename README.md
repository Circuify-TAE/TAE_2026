# Git Cheat Sheet

## 1. Configuración inicial

```bash
git config --global user.name "Tu Nombre"
git config --global user.email "tu@email.com"
git config --list
```

---

## 2. Crear o clonar repositorios

```bash
git init
git clone URL
```

---

## 3. Estado e historial

```bash
git status
git log
git log --oneline
git diff
```

---

## 4. Flujo básico de trabajo

```bash
git add archivo.txt
git add .
git commit -m "Mensaje"
git commit -am "Mensaje"
```

---

## 5. Ramas (branches)

```bash
git branch
git branch nombre-rama
git checkout nombre-rama
git checkout -b nueva-rama
git switch nombre-rama
git merge rama
git branch -d rama
```

---

## 6. Repositorios remotos

```bash
git remote -v
git remote add origin URL
git push origin main
git pull origin main
git fetch
```

---

## 7. Deshacer cambios

```bash
git restore archivo.txt
git restore --staged archivo.txt
git reset HEAD~1
git reset --hard HEAD~1
git revert HASH
```

---

## 8. Stash

```bash
git stash
git stash list
git stash apply
git stash drop
```

---

## 9. Tags

```bash
git tag
git tag v1.0.0
git push origin v1.0.0
git push --tags
```

---

## 10. Flujo típico de trabajo en equipo

```bash
git pull origin main
git checkout -b feature/nueva-funcion
git add .
git commit -m "Agrega nueva función"
git push origin feature/nueva-funcion
```

---

## Tips rápidos

* `git status` practicamente antes de cualquier push.
* Haz commits pequeños y con mensajes claros, iniciar con una accion (add, remove, fix, update, etc).
* Antes de `git push`, casi siempre: `git pull`.
* Usa ramas `{feature bugfix update}/proyecto/tu_nombre/nombre_funcion`.

