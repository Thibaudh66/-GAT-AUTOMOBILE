# Garage Atelier — Application de gestion de planning

Application web de gestion de planning d'atelier et de prise de rendez-vous en ligne pour garage automobile.

## Stack technique

- **Frontend** : Next.js 14 (App Router) + TypeScript + Tailwind CSS
- **Backend** : Supabase (PostgreSQL + Auth + Realtime + Storage)
- **Déploiement** : Netlify
- **Notifications** : Resend (email) + Brevo (SMS) — Sprint S7
- **Sync calendrier** : Google Calendar API — Sprint S8

## Statut du projet

**Sprint en cours** : S0 — Fondations
**Sprints à venir** : S1 (schéma DB ✅), S2 (auth & CRUD), S3 (ressources), S4 (planning), S5 (espace client), S6 (validation RDV), S7 (notifications), S8 (Google Calendar), S9 (KPI & finitions)

---

## Premier démarrage — Installation locale

### 1. Pré-requis

- **Node.js 20+** : https://nodejs.org (version LTS)
- **Un éditeur de code** : VS Code recommandé
- **Compte Supabase** avec le projet créé et les 4 fichiers SQL exécutés
- **Compte GitHub** (gratuit) pour héberger le code
- **Compte Netlify** (gratuit) pour le déploiement

### 2. Installation des dépendances

Ouvrir un terminal dans ce dossier et lancer :

```bash
npm install
```

Cela installe ~250 paquets et prend 1 à 2 minutes.

### 3. Configuration des variables d'environnement

Copier le fichier d'exemple :

```bash
cp .env.example .env.local
```

Ouvrir `.env.local` et renseigner les 3 valeurs Supabase, qu'on trouve dans :
Dashboard Supabase → Project Settings → API

- `NEXT_PUBLIC_SUPABASE_URL` : URL du projet (https://xxx.supabase.co)
- `NEXT_PUBLIC_SUPABASE_ANON_KEY` : clé `anon` (publique, exposée côté client)
- `SUPABASE_SERVICE_ROLE_KEY` : clé `service_role` (privée, jamais exposée)

### 4. Lancer le serveur de développement

```bash
npm run dev
```

Ouvrir http://localhost:3000 dans le navigateur. La page d'accueil doit s'afficher.

### 5. Tester la connexion admin

Aller sur http://localhost:3000/connexion et se connecter avec l'admin créé dans Supabase (voir Phase 3 — étape 3 du tutoriel).

Si tout fonctionne, vous êtes redirigé vers `/tableau-de-bord`.

---

## Déploiement sur Netlify

### Étape A — Pousser le code sur GitHub

1. Créer un nouveau repository sur https://github.com/new
   - Nom : `garage-atelier`
   - Visibilité : Private (recommandé)
   - NE PAS cocher "Initialize with README"

2. Dans le terminal, depuis ce dossier :

```bash
git init
git add .
git commit -m "feat: initial commit — sprint S0 fondations"
git branch -M main
git remote add origin https://github.com/VOTRE_USER/garage-atelier.git
git push -u origin main
```

### Étape B — Connecter le repo à Netlify

1. Aller sur https://app.netlify.com
2. Cliquer sur **Add new site** → **Import an existing project**
3. Choisir **Deploy with GitHub** et autoriser l'accès
4. Sélectionner le repo `garage-atelier`
5. Netlify détecte Next.js automatiquement. Garder les paramètres par défaut :
   - Build command : `npm run build`
   - Publish directory : `.next`
   - Functions directory : (vide)

### Étape C — Configurer les variables d'environnement

Sur Netlify, **Site settings → Environment variables**, ajouter :

| Variable | Valeur |
|---|---|
| `NEXT_PUBLIC_SUPABASE_URL` | URL Supabase |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | clé anon |
| `SUPABASE_SERVICE_ROLE_KEY` | clé service_role |
| `NEXT_PUBLIC_APP_URL` | URL Netlify (ex. https://garage-atelier.netlify.app) |
| `NEXT_PUBLIC_GARAGE_NAME` | Nom du garage |
| `NEXT_PUBLIC_GARAGE_PHONE` | Téléphone |
| `NEXT_PUBLIC_GARAGE_EMAIL` | Email |

Important : Netlify a deux types de variables. Ces variables doivent être en "Plain text" et **non** chiffrées (sinon le runtime ne peut pas les lire à la volée).

### Étape D — Déclencher le premier déploiement

Une fois les variables sauvegardées, aller dans **Deploys** et cliquer **Trigger deploy** → **Clear cache and deploy site**.

Le build prend 2 à 5 minutes. À la fin, vous obtenez une URL `https://xxxxx.netlify.app`.

### Étape E — Mettre à jour les redirections Supabase

Dans Supabase Dashboard → Authentication → URL Configuration :
- **Site URL** : votre URL Netlify
- **Redirect URLs** : ajouter `https://votre-url.netlify.app/api/auth/callback`

Sans cette étape, les magic links et OAuth callbacks ne fonctionneront pas.

---

## Structure du projet

```
src/
├── app/                          # Routes Next.js (App Router)
│   ├── (admin)/                  # Espace admin protégé
│   ├── (auth)/                   # Connexion / inscription
│   ├── (client)/                 # Espace client privé
│   ├── (mecanicien)/             # Espace mécanicien
│   ├── (public)/                 # Pages publiques
│   ├── api/                      # Route handlers (REST endpoints)
│   ├── globals.css               # Variables CSS + Tailwind
│   ├── layout.tsx                # Root layout
│   ├── error.tsx                 # Erreur globale
│   └── not-found.tsx             # Page 404
├── components/                   # Composants React partagés
├── lib/                          # Code métier non-React
│   ├── auth/                     # Helpers d'authentification
│   ├── supabase/                 # Clients Supabase (3 contextes)
│   ├── utils/                    # Utilitaires (cn, dates, etc.)
│   └── validations/              # Schémas Zod
├── types/                        # Types TypeScript
└── hooks/                        # Hooks React partagés

middleware.ts                     # Auth + redirections globales
netlify.toml                      # Config Netlify
supabase/migrations/              # Migrations SQL versionnées
```

## Scripts disponibles

| Commande | Action |
|---|---|
| `npm run dev` | Lance le serveur de développement |
| `npm run build` | Construit la version production |
| `npm run start` | Lance le serveur en mode production |
| `npm run lint` | Vérifie le code avec ESLint |
| `npm run type-check` | Vérifie les types TypeScript |
| `npm run format` | Formate tous les fichiers avec Prettier |

## Sécurité

- **RLS activé sur toutes les tables** : aucun client web ne peut requêter directement la base sans passer par les politiques de sécurité PostgreSQL.
- **`service_role` jamais exposé côté navigateur** : utilisée uniquement dans les Server Actions et Edge Functions.
- **Cookies de session httpOnly** : géré automatiquement par `@supabase/ssr`.
- **Headers de sécurité** : configurés dans `netlify.toml` (X-Frame-Options, HSTS, etc.).
- **Middleware d'auth** : protège toutes les routes privées avant même le rendu serveur.

## Prochaines étapes

Le sprint S2 ajoutera :
- Le CRUD complet des mécaniciens, clients, véhicules
- La page paramètres garage (horaires, granularité)
- Les composants UI shadcn/ui (Button, Input, Dialog, etc.)
- La vue planning de base

Pour générer les types Supabase automatiquement (recommandé avant S2) :

```bash
npm install -g supabase
# Modifier le script supabase:types dans package.json avec votre project-id
npm run supabase:types
```
