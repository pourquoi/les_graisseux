<?php

namespace App\Entity\Translation;

use Doctrine\ORM\Mapping as ORM;
use Locastic\ApiPlatformTranslationBundle\Model\AbstractTranslation;
use Symfony\Component\Serializer\Annotation\Groups;

/**
 * @ORM\Entity()
 */
class EnergyTranslation extends AbstractTranslation
{
    /**
     * @var int
     * @ORM\Id()
     * @ORM\GeneratedValue()
     * @ORM\Column(type="integer")
     */
    private $id;

    /**
     * @ORM\Column(type="string")
     *
     * @Groups({"energy:read", "energy:write", "translations"})
     */
    private $name;

    /**
     * @ORM\ManyToOne(targetEntity="App\Entity\Energy", inversedBy="translations")
     */
    protected $translatable;

    /**
     * @ORM\Column(type="string")
     *
     * @Groups({"energy:write", "translations"})
     */
    protected $locale;

    public function getId(): int
    {
        return $this->id;
    }

    public function getName(): ?string
    {
        return $this->name;
    }

    public function setName(?string $name): void
    {
        $this->name = $name;
    }


}