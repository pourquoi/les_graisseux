<?php

namespace App\Controller;

use App\Entity\Api\EmailVerification;
use App\Entity\User;
use Doctrine\ORM\EntityManagerInterface;
use Lexik\Bundle\JWTAuthenticationBundle\Encoder\JWTEncoderInterface;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Twig\Environment;

class EmailVerificationController
{
    private $JWTEncoder;
    private $em;
    private $twig;

    public function __construct(JWTEncoderInterface $JWTEncoder, EntityManagerInterface $em, Environment $twig)
    {
        $this->JWTEncoder = $JWTEncoder;
        $this->em = $em;
        $this->twig = $twig;
    }

    public function __invoke(EmailVerification $data, Request $request)
    {
        try {
            $data = $this->JWTEncoder->decode($data->token);
        } catch( \Exception $e ) {
            return new Response("Invalid token", 400);
        }

        /** @var User $user */
        if( isset($data['user_id']) && ($user = $this->em->getRepository(User::class)->find($data['user_id'])) ) {
            $user->setEmailVerificationRequired(false);
            $this->em->flush();

            // unfortunately not working with current api platform
            // https://github.com/api-platform/api-platform/issues/1682
            if (in_array('text/html', $request->getAcceptableContentTypes())) {
                return new Response($this->twig->render('transactions/email_verification.html.twig'));
            }

            return new Response("", 200);
        } else {
            return new Response("Invalid token", 400);
        }
    }
}