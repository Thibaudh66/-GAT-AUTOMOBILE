import { z } from 'zod';

export const loginSchema = z.object({
  email: z
    .string()
    .min(1, { message: 'L’email est requis' })
    .email({ message: 'Email invalide' }),
  password: z
    .string()
    .min(1, { message: 'Le mot de passe est requis' })
    .min(8, { message: 'Le mot de passe doit faire au moins 8 caractères' }),
});

export type LoginInput = z.infer<typeof loginSchema>;
