class SupabaseConfig {
  // Remplacez ces valeurs par vos vraies clés Supabase
  static const String supabaseUrl = 'https://votre-projet.supabase.co';
  static const String supabaseAnonKey = 'votre-clé-anonyme-ici';
  
  // Tables de base de données
  static const String teamsTable = 'teams';
  static const String matchesTable = 'matches';
  static const String userProfilesTable = 'user_profiles';
  static const String betsTable = 'bets';
  static const String globalStatsTable = 'global_stats';
  static const String matchEventsTable = 'match_events';
  static const String eventReactionsTable = 'event_reactions';
  
  // Policies et RLS
  static const bool enableRLS = true;
  
  // Configuration de stockage
  static const String storageAvatarsBucket = 'avatars';
  static const String storageTeamLogosBucket = 'team-logos';
}

// SQL pour créer les tables Supabase
const String createTablesSQL = '''
-- Table des équipes
CREATE TABLE IF NOT EXISTS teams (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  city TEXT NOT NULL,
  arena TEXT NOT NULL,
  logo_url TEXT,
  points INTEGER DEFAULT 0,
  wins INTEGER DEFAULT 0,
  losses INTEGER DEFAULT 0,
  overtime_losses INTEGER DEFAULT 0,
  goals_for INTEGER DEFAULT 0,
  goals_against INTEGER DEFAULT 0,
  players TEXT[] DEFAULT '{}',
  staff TEXT[] DEFAULT '{}',
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des matchs
CREATE TABLE IF NOT EXISTS matches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  home_team_id UUID REFERENCES teams(id),
  away_team_id UUID REFERENCES teams(id),
  date TIMESTAMP WITH TIME ZONE NOT NULL,
  status TEXT NOT NULL DEFAULT 'scheduled',
  home_score INTEGER,
  away_score INTEGER,
  venue TEXT NOT NULL,
  period INTEGER,
  time_remaining TEXT,
  is_playoffs BOOLEAN DEFAULT FALSE,
  attendance INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des profils utilisateurs
CREATE TABLE IF NOT EXISTS user_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  username TEXT UNIQUE NOT NULL,
  favorite_team_id UUID REFERENCES teams(id),
  total_pucks INTEGER DEFAULT 1000,
  successful_bets INTEGER DEFAULT 0,
  total_bets INTEGER DEFAULT 0,
  current_streak INTEGER DEFAULT 0,
  ranking INTEGER DEFAULT 1,
  avatar_url TEXT,
  last_login_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  total_login_days INTEGER DEFAULT 1,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des paris
CREATE TABLE IF NOT EXISTS bets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id),
  match_id UUID REFERENCES matches(id),
  prediction TEXT NOT NULL,
  pucks_wagered INTEGER NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending',
  placed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  pucks_won INTEGER,
  odds DECIMAL(5,2) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des statistiques globales
CREATE TABLE IF NOT EXISTS global_stats (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  total_bets INTEGER DEFAULT 0,
  total_pucks INTEGER DEFAULT 0,
  active_users INTEGER DEFAULT 0,
  top_team TEXT,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes pour optimiser les performances
CREATE INDEX IF NOT EXISTS idx_matches_date ON matches(date);
CREATE INDEX IF NOT EXISTS idx_matches_status ON matches(status);
CREATE INDEX IF NOT EXISTS idx_matches_teams ON matches(home_team_id, away_team_id);
CREATE INDEX IF NOT EXISTS idx_bets_user ON bets(user_id);
CREATE INDEX IF NOT EXISTS idx_bets_match ON bets(match_id);
CREATE INDEX IF NOT EXISTS idx_user_profiles_ranking ON user_profiles(ranking);

-- Fonctions pour mettre à jour les timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS \$\$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
\$\$ language 'plpgsql';

-- Triggers pour les timestamps
CREATE TRIGGER update_teams_updated_at BEFORE UPDATE ON teams FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_matches_updated_at BEFORE UPDATE ON matches FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_user_profiles_updated_at BEFORE UPDATE ON user_profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_bets_updated_at BEFORE UPDATE ON bets FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Table des événements de match
CREATE TABLE IF NOT EXISTS match_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  match_id UUID REFERENCES matches(id),
  type TEXT NOT NULL,
  description TEXT NOT NULL,
  player_id TEXT,
  player_name TEXT,
  team_id UUID REFERENCES teams(id),
  minute INTEGER NOT NULL,
  period INTEGER,
  details JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des réactions aux événements
CREATE TABLE IF NOT EXISTS event_reactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID REFERENCES match_events(id),
  user_id UUID REFERENCES auth.users(id),
  username TEXT NOT NULL,
  emoji TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes additionnels
CREATE INDEX IF NOT EXISTS idx_match_events_match ON match_events(match_id);
CREATE INDEX IF NOT EXISTS idx_match_events_minute ON match_events(minute);
CREATE INDEX IF NOT EXISTS idx_event_reactions_event ON event_reactions(event_id);
CREATE INDEX IF NOT EXISTS idx_event_reactions_user ON event_reactions(user_id);

-- Triggers pour les événements
CREATE TRIGGER update_match_events_updated_at BEFORE UPDATE ON match_events FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Policies RLS (Row Level Security)
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE bets ENABLE ROW LEVEL SECURITY;
ALTER TABLE event_reactions ENABLE ROW LEVEL SECURITY;

-- Politique : les utilisateurs peuvent voir et modifier leur propre profil
CREATE POLICY "Users can view own profile" ON user_profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON user_profiles
  FOR UPDATE USING (auth.uid() = id);

-- Politique : les utilisateurs peuvent voir leurs propres paris
CREATE POLICY "Users can view own bets" ON bets
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own bets" ON bets
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Politique : lecture publique pour les équipes et matchs
CREATE POLICY "Teams are viewable by everyone" ON teams
  FOR SELECT USING (true);

CREATE POLICY "Matches are viewable by everyone" ON matches
  FOR SELECT USING (true);

-- Politique : lecture publique pour les événements
CREATE POLICY "Match events are viewable by everyone" ON match_events
  FOR SELECT USING (true);

-- Politique : réactions visibles par tous, ajout/suppression par propriétaire
CREATE POLICY "Event reactions are viewable by everyone" ON event_reactions
  FOR SELECT USING (true);

CREATE POLICY "Users can add their own reactions" ON event_reactions
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own reactions" ON event_reactions
  FOR DELETE USING (auth.uid() = user_id);
''';

// Données d'exemple pour peupler la base
const String sampleDataSQL = '''
-- Insérer les équipes de la Ligue Magnus
INSERT INTO teams (name, city, arena, description) VALUES
('Brûleurs de Loups', 'Grenoble', 'Patinoire Pôle Sud', 'Équipe de Grenoble évoluant en Ligue Magnus'),
('Dragons', 'Rouen', 'Patinoire de l''Île Lacroix', 'Équipe de Rouen évoluant en Ligue Magnus'),
('Gothiques', 'Amiens', 'Coliséum', 'Équipe d''Amiens évoluant en Ligue Magnus'),
('Ducs', 'Angers', 'Patinoire Iceparc', 'Équipe d''Angers évoluant en Ligue Magnus'),
('Boxers', 'Bordeaux', 'Patinoire Mériadeck', 'Équipe de Bordeaux évoluant en Ligue Magnus'),
('Diables Rouges', 'Briançon', 'Patinoire René Froger', 'Équipe de Briançon évoluant en Ligue Magnus'),
('Pionniers', 'Chamonix', 'Patinoire Richard Bozon', 'Équipe de Chamonix évoluant en Ligue Magnus'),
('Jokers', 'Cergy-Pontoise', 'Patinoire Aren''ice', 'Équipe de Cergy-Pontoise évoluant en Ligue Magnus'),
('Rapaces', 'Gap', 'Patinoire Alp''Arena', 'Équipe de Gap évoluant en Ligue Magnus'),
('Scorpions', 'Mulhouse', 'Patinoire de l''Illberg', 'Équipe de Mulhouse évoluant en Ligue Magnus'),
('Aigles', 'Nice', 'Patinoire Jean Bouin', 'Équipe de Nice évoluant en Ligue Magnus'),
('Étoile Noire', 'Strasbourg', 'Patinoire Iceberg', 'Équipe de Strasbourg évoluant en Ligue Magnus'),
('Hormadi', 'Anglet', 'Patinoire de la Barre', 'Équipe d''Anglet évoluant en Ligue Magnus'),
('Yétis', 'Mont-Blanc', 'Patinoire du Mont-Blanc', 'Équipe du Mont-Blanc évoluant en Ligue Magnus');

-- Insérer les statistiques globales initiales
INSERT INTO global_stats (total_bets, total_pucks, active_users, top_team) VALUES
(0, 0, 0, 'Brûleurs de Loups');
''';