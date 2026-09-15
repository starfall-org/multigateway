package org.starfall.multigateway

import android.content.Context
import androidx.room.Room
import androidx.sqlite.db.SupportSQLiteDatabase
import androidx.sqlite.db.SupportSQLiteOpenHelper
import androidx.sqlite.db.framework.FrameworkSQLiteOpenHelperFactory
import androidx.test.core.app.ApplicationProvider
import org.junit.Assert.*
import org.junit.Test
import org.starfall.multigateway.data.local.db.AppDatabase
import org.starfall.multigateway.data.local.db.SecretCipher
import java.util.UUID

/** Run on Android: real Room schema validation and real Keystore, never a fake cipher. */
class CredentialMigrationTest {
    @Test fun v1UpgradePreservesRowsAndEncryptsCredentialsIdempotently() {
        val context = ApplicationProvider.getApplicationContext<Context>()
        val name = "migration-${UUID.randomUUID()}"
        val helper = FrameworkSQLiteOpenHelperFactory().create(SupportSQLiteOpenHelper.Configuration.builder(context)
            .name(name).callback(object : SupportSQLiteOpenHelper.Callback(1) {
                override fun onCreate(db: SupportSQLiteDatabase) {
                    db.execSQL("CREATE TABLE conversations (id TEXT NOT NULL PRIMARY KEY, title TEXT NOT NULL, createdAt INTEGER NOT NULL, updatedAt INTEGER NOT NULL, messagesJson TEXT NOT NULL, tokenCount INTEGER, providerId TEXT NOT NULL, modelId TEXT NOT NULL, profileId TEXT)")
                    db.execSQL("CREATE TABLE chat_profiles (id TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL, icon TEXT, configJson TEXT NOT NULL, activeMcpJson TEXT NOT NULL, activeModelToolsJson TEXT NOT NULL)")
                    db.execSQL("CREATE TABLE llm_providers (id TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL, type TEXT NOT NULL, baseUrl TEXT NOT NULL, authJson TEXT NOT NULL, configJson TEXT NOT NULL, icon TEXT)")
                    db.execSQL("CREATE TABLE llm_models (id TEXT NOT NULL PRIMARY KEY, modelsJson TEXT NOT NULL)")
                    db.execSQL("CREATE TABLE mcp_servers (id TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL, protocol TEXT NOT NULL, url TEXT, headersJson TEXT)")
                    db.execSQL("INSERT INTO conversations VALUES ('c','keep',1,2,'[]',NULL,'p','m','profile')")
                    db.execSQL("INSERT INTO chat_profiles VALUES ('profile','keep',NULL,'{}','[]','[]')")
                    db.execSQL("INSERT INTO llm_providers VALUES ('p','keep','OPENAI','https://example.com','legacy-secret','{}',NULL)")
                    db.execSQL("INSERT INTO mcp_servers VALUES ('s','keep','SSE',NULL,'legacy-header')")
                }
                override fun onUpgrade(db: SupportSQLiteDatabase, oldVersion: Int, newVersion: Int) = Unit
            }).build())
        helper.writableDatabase
        helper.close()
        val room = Room.databaseBuilder(context, AppDatabase::class.java, name).addMigrations(AppDatabase.MIGRATION_1_2).build()
        try {
            val db = room.openHelper.writableDatabase // Room validates every migrated table.
            db.execSQL("INSERT INTO speech_services VALUES ('speech','keep','p','voice',1.0,1.0,'speech-secret')")
            AppDatabase.encryptLegacySecrets(db)
            fun field(sql: String): String = db.query(sql).use { assertTrue(it.moveToFirst()); it.getString(0) }
            val encrypted = field("SELECT authJson FROM llm_providers")
            assertNotEquals("legacy-secret", encrypted)
            assertEquals("legacy-secret", SecretCipher.decrypt(encrypted))
            assertEquals("legacy-header", SecretCipher.decrypt(field("SELECT headersJson FROM mcp_servers")))
            assertEquals("speech-secret", SecretCipher.decrypt(field("SELECT apiKey FROM speech_services")))
            assertEquals("keep", field("SELECT title FROM conversations"))
            assertEquals("keep", field("SELECT name FROM chat_profiles"))
            AppDatabase.encryptLegacySecrets(db)
            assertEquals(encrypted, field("SELECT authJson FROM llm_providers"))
        } finally { room.close(); context.deleteDatabase(name) }
    }
    @Test fun corruptedEnvelopeFailsWithoutPlaintextFallback() {
        val encrypted = SecretCipher.encrypt("secret")
        val error = runCatching { SecretCipher.decrypt(encrypted.dropLast(8) + "AAAAAAAA") }.exceptionOrNull()
        assertNotNull(error)
    }
}
