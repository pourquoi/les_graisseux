<?php

namespace App\Entity\Api;

use ApiPlatform\Core\Annotation\ApiProperty;
use ApiPlatform\Core\Annotation\ApiResource;
use App\Controller\EmailVerificationController;

/**
 * @ApiResource(
 *     formats={"html", "json", "jsonld"},
 *     collectionOperations={},
 *     itemOperations={
 *         "get"={
 *             "method"="GET",
 *             "requirements"={"id"=".+"},
 *             "controller"=EmailVerificationController::class
 *         }
 *     }
 * )
 */
class EmailVerification
{
    /**
     * @var string
     * @ApiProperty(identifier=true)
     */
    public $token;

    public function __construct($token)
    {
        $this->token = $token;
    }
}