<?php

namespace App\EventSubscriber;

use ApiPlatform\Core\EventListener\EventPriorities;
use App\Entity\User;
use Lcobucci\JWT\Builder;
use Lexik\Bundle\JWTAuthenticationBundle\Encoder\JWTEncoderInterface;
use Symfony\Bridge\Twig\Mime\TemplatedEmail;
use Symfony\Component\EventDispatcher\EventSubscriberInterface;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpKernel\Event\ViewEvent;
use Symfony\Component\HttpKernel\KernelEvents;
use Symfony\Component\Mailer\MailerInterface;
use Symfony\Component\Mime\Address;
use Symfony\Component\Routing\RouterInterface;
use Symfony\Contracts\Translation\TranslatorInterface;

class UserMailVerificationSubscriber implements EventSubscriberInterface
{
    private $mailer;
    private $JWTEncoder;
    private $router;
    private $translator;

    public function __construct(MailerInterface $mailer, JWTEncoderInterface $JWTEncoder, TranslatorInterface $translator, RouterInterface $router)
    {
        $this->mailer = $mailer;
        $this->JWTEncoder = $JWTEncoder;
        $this->router = $router;
        $this->translator = $translator;
    }

    public static function getSubscribedEvents()
    {
        return [
            KernelEvents::VIEW => ['sendMail', EventPriorities::POST_WRITE]
        ];
    }

    public function sendMail(ViewEvent $event): void
    {
        /** @var User $user */
        $user = $event->getControllerResult();
        $method = $event->getRequest()->getMethod();

        if( !($user instanceof User) || !$user->isEmailVerificationRequired() || Request::METHOD_POST !== $method || $event->getRequest()->getRequestUri() != '/api/users') {
            return;
        }

        $token = $this->JWTEncoder->encode(['user_id' => $user->getId()]);

        $message = (new TemplatedEmail())
            ->from('no-reply@lesgraisseux.com')
            ->to(new Address($user->getEmail()))
            ->subject($this->translator->trans('email.email_verification.subject'))
            ->htmlTemplate('emails/email_verification.html.twig')
            ->context([
                'verification_url' => $this->router->generate('app_transaction_emailverification', ['token'=>$token], RouterInterface::ABSOLUTE_URL),
                'verification_api_url' => $this->router->generate('api_email_verifications_get_item', ['id'=>$token], RouterInterface::ABSOLUTE_URL)
            ]);

        $this->mailer->send($message);
    }
}