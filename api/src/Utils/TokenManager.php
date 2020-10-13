<?php

namespace App\Utils;

use Lexik\Bundle\JWTAuthenticationBundle\Encoder\JWTEncoderInterface;

class TokenManager
{
    private $encoder;

    public function __construct(JWTEncoderInterface $encoder)
    {
        $this->encoder = $encoder;
        print(get_class($encoder));
    }

    public function create($payload)
    {
        return $this->encoder->encode($payload);
    }

    public function check($value)
    {
        return $this->encoder->decode($value);
    }
}