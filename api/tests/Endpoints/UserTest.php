<?php

namespace App\Tests\Endpoints;

use App\Entity\User;
use App\Repository\UserRepository;
use App\Utils\TokenManager;
use Hautelook\AliceBundle\PhpUnit\RefreshDatabaseTrait;
use Lexik\Bundle\JWTAuthenticationBundle\Encoder\JWTEncoderInterface;
use Symfony\Component\HttpClient\Exception\ClientException;
use Symfony\Component\Mailer\DataCollector\MessageDataCollector;

class UserTest extends Base
{
    use RefreshDatabaseTrait;

    public function testGetCollection(): void
    {
        $response = static::createClient()->request('GET', '/api/users?username=bob');

        $this->assertResponseIsSuccessful();

        $this->assertJsonContains(['hydra:totalItems' => 1]);

        $user = json_decode($response->getContent(), true)['hydra:member'][0];

        $this->assertArrayNotHasKey('email', $user);

    }

    public function testSecretAttribute(): void
    {
        $client = static::createClient();
        $response = $client->request('GET', '/api/users?username=bob');
        $user = json_decode($response->getContent(), true)['hydra:member'][0];
        $this->assertArrayNotHasKey('email', $user);

        $response = $client->request('GET', $user['@id']);
        $user = json_decode($response->getContent(), true);
        $this->assertArrayNotHasKey('email', $user);

        self::login($client, 'bob@example.com', 'pass1234');
        $response = $client->request('GET', $user['@id']);
        $user = json_decode($response->getContent(), true);
        $this->assertArrayHasKey('email', $user);
    }

    public function testLogin(): void
    {
        $client = static::createClient();

        $response = $client->request( 'POST', '/authentication_token', ['json' => [
            'email' => 'bob@example.com',
            'password' => 'pass1234'
        ]]);
        $this->assertResponseIsSuccessful();
        $token = $response->toArray();
        $this->arrayHasKey('token');
        $this->assertNotEmpty($token['token']);
        $this->arrayHasKey('uid');
        $this->assertNotEmpty($token['uid']);

        $response = $client->request( 'POST', '/authentication_token', ['json' => [
            'email' => 'unverified@example.com',
            'password' => 'pass1234'
        ]]);
        $this->assertEquals(200, $response->getStatusCode());

        $response = $client->request( 'POST', '/authentication_token', ['json' => [
            'email' => 'bob@example.com',
            'password' => 'OOOOOOOOOOOOO'
        ]]);
        $this->assertEquals(401, $response->getStatusCode());
    }

    public function testEmailVerification(): void
    {
        $client = static::createClient();
        $container = self::$kernel->getContainer();
        /** @var User $user */
        $user = $container->get('doctrine')->getRepository(User::class)->findOneByEmail('unverified@example.com');
        $this->assertTrue($user->isEmailVerificationRequired());

        /** @var JWTEncoderInterface $encoder */
        $encoder = $container->get('lexik_jwt_authentication.encoder');
        $token = $encoder->encode(['user_id'=>$user->getId()]);

        $client->request('GET', '/api/email_verifications/' . $token);
        $this->assertResponseIsSuccessful();

        $container->get('doctrine')->getManager()->refresh($user);
        $this->assertFalse($user->isEmailVerificationRequired());

        $response = $client->request('GET', '/api/email_verifications/OOOOOOOOOOOOO');
        $this->assertEquals(400, $response->getStatusCode());
    }

    public function testRegister(): void
    {
        $client = static::createClient();
        $client->enableProfiler();

        $response = $client->request('POST', '/api/users', ['json' => [
            'email' => 'luke@example.com',
            'password' => 'pass1234'
        ]]);

        $this->assertResponseIsSuccessful();

        if ($profile = $client->getProfile()) {
            /** @var MessageDataCollector $collector */
            $collector = $profile->getCollector('mailer');
            $this->assertCount(1, $collector->getEvents()->getMessages());
        }
    }

    public function testPatch(): void
    {
        $client = static::createClient();
        $data = static::login($client, 'alice@example.com', 'pass1234');

        $response = $client->request('PATCH', '/api/users/' . $data['uid'], ['headers'=>['content-type'=>'application/merge-patch+json'], 'json' => [
            'username' => 'lapin'
        ]]);

        $this->assertResponseIsSuccessful();
    }
}
