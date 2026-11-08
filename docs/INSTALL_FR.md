# Installer Roblox Performance Analyzer (FR)

**Statut :** version initiale non encore testée dans Roblox Studio par l'auteur de cette archive. Testez d'abord dans une place temporaire, pas dans votre jeu principal.

1. Décompressez le ZIP puis ouvrez `plugin/RobloxPerformanceAnalyzer.lua` avec un éditeur de texte.
2. Copiez **tout** le code.
3. Dans Roblox Studio, ouvrez une place de test et affichez **Explorer**.
4. Dans **ServerStorage**, ajoutez un `Script` temporaire et collez le code.
5. Sélectionnez ce `Script`, utilisez la fonction Studio **Save as Local Plugin / Enregistrer en tant que plugin local**, puis validez.
6. Supprimez le `Script` temporaire de `ServerStorage`. Le code du plugin ne doit pas être exécuté dans le jeu.
7. Dans l'onglet **Plugins**, cliquez sur **Performance Analyzer**.
8. Cliquez sur **Scan Workspace** pour analyser `Workspace`, ou sélectionnez un objet dans Explorer et cliquez sur **Scan selection**.
9. Cliquez sur une alerte pour sélectionner l'objet concerné dans Explorer.
10. Cliquez sur **Report** pour afficher le compte rendu texte, puis revenez à **Findings**.

### Tester avec une scène de démonstration

Dans une place de test, copiez `examples/create_demo_scene.lua` dans la **Command Bar / barre de commandes** de Studio puis exécutez-le. Sélectionnez le modèle `PerformanceAnalyzer_Demo`, cliquez sur **Scan selection** : deux alertes de particules sont attendues. Supprimez le modèle de démonstration après le test.

### Limites

Il ne s'agit **pas** d'un benchmark. Le plugin n'est pas capable de mesurer les FPS, les pics CPU ou les pertes de mémoire. Une alerte désigne un réglage à examiner avec les outils Roblox et sur appareil réel. Les seuils sont arbitraires et documentés dans `docs/RULES.md`.

Sources officielles :
- https://create.roblox.com/docs/studio/plugins
- https://create.roblox.com/docs/performance-optimization
