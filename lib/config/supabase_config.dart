/// Public client configuration for the Calendario Supabase project.
/// The publishable key is intended for mobile/web clients; access is enforced by RLS.
bool supabaseInitialized = false;

abstract final class SupabaseConfig {
  static const url = 'https://bxvthyegbveqihlcsaxz.supabase.co';
  static const publishableKey =
      'sb_publishable_jUzFS5NV1v7qMNJFY11pHw_ly719uN5';
}
