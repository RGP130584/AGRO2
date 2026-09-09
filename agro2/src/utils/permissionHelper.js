const PERMISSION_KEY = 'agro2_role_permissions';

export const DEFAULT_PERMISSIONS = {
  colaborador: {
    dashboard: true,
    rebanho: true,
    saude: true,
    nutricao: true,
    pesagem: true,
    estoque: true,
    financeiro: false,
    relatorios: true,
    equipe: false,
    sync: true,
  },
  veterinario: {
    dashboard: true,
    rebanho: true,
    saude: true,
    nutricao: true,
    pesagem: true,
    estoque: true,
    financeiro: false,
    relatorios: true,
    equipe: false,
    sync: true,
  },
  proprietario: {
    dashboard: true,
    rebanho: true,
    saude: true,
    nutricao: true,
    pesagem: true,
    estoque: true,
    financeiro: true,
    relatorios: true,
    equipe: true,
    sync: true,
  }
};

export function getRolePermissions() {
  try {
    const stored = localStorage.getItem(PERMISSION_KEY);
    if (stored) {
      return { ...DEFAULT_PERMISSIONS, ...JSON.parse(stored) };
    }
  } catch (e) {
    console.error('Erro ao ler permissoes:', e);
  }
  return DEFAULT_PERMISSIONS;
}

export function saveRolePermissions(newPermissions) {
  try {
    localStorage.setItem(PERMISSION_KEY, JSON.stringify(newPermissions));
    window.dispatchEvent(new Event('agro2_permissions_updated'));
  } catch (e) {
    console.error('Erro ao salvar permissoes:', e);
  }
}

export function canAccessModule(perfil = 'proprietario', pageId = 'dashboard') {
  if (perfil === 'proprietario') return true; // Proprietario tem acesso mestre
  const perms = getRolePermissions();
  const rolePerms = perms[perfil] || perms.colaborador;

  // Normalização de sub-páginas (ex: rebanho_novo -> rebanho, saude_aplicar -> saude)
  const basePage = pageId.split('_')[0];
  if (rolePerms[basePage] !== undefined) {
    return rolePerms[basePage];
  }
  return true;
}
