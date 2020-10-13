<?php

namespace App\Controller;

use App\Entity\Api\EmailVerification;
use App\Entity\User;
use Doctrine\ORM\EntityManagerInterface;
use Lexik\Bundle\JWTAuthenticationBundle\Encoder\JWTEncoderInterface;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

class EmailVerificationController
{
    private $JWTEncoder;
    private $em;

    public function __construct(JWTEncoderInterface $JWTEncoder, EntityManagerInterface $em)
    {
        $this->JWTEncoder = $JWTEncoder;
        $this->em = $em;
    }

    public function __invoke(EmailVerification $data)
    {
        try {
            $data = $this->JWTEncoder->decode($data->token);
        } catch( \Exception $e ) {
            return new Response("", 400);
        }

        /** @var User $user */
        if( isset($data['user_id']) && ($user = $this->em->getRepository(User::class)->find($data['user_id'])) ) {
            $user->setEmailVerificationRequired(false);
            $this->em->flush();

            return $user;
        } else {
            return new Response("", 400);
        }
    }
}