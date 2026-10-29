import * as bcrypt from 'bcrypt';

describe('bcrypt migration compatibility', () => {
  // Fixture generated with bcrypt 5.1.1 before migrating; contains no user credentials.
  const legacyHash =
    '$2b$04$8LMBg/feGgMhHDq/jwbR6Owteye5xJXHnFj6cByBIRain3M88.YLO';

  it('verifies existing hashes without forcing password resets', () => {
    expect(
      bcrypt.compareSync('migration-compatibility-password', legacyHash),
    ).toBe(true);
    expect(bcrypt.compareSync('wrong-password', legacyHash)).toBe(false);
  });

  it('creates and verifies hashes with the new native module', async () => {
    const hash = await bcrypt.hash('new-migration-password', 4);
    expect(await bcrypt.compare('new-migration-password', hash)).toBe(true);
    expect(await bcrypt.compare('wrong-password', hash)).toBe(false);
  });
});
